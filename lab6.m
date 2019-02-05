%% lab6
%Kenneth Ritchings, Ethan Poole, Team 5

%% step 1
%init

clear all;
close all;
clc;

cie=loadCIEdata;

%% step 2
%calculate and read the values of the 'ramps_plus' chart automatically.

%% step 3
%load_ramps_data.m
% parse the ramps_plus.ti3 file and load the measured XYZ data into the
% workspace
% 11/6/13 jaf
% modified for new Argyll v1.8.3 .ti3 format to skip skip 22 header % lines instead of 29
% 4/12/16 jaf

% read in the Argyll ramp data
% unscramble the data file and extract the blacks, whites, and ramps data
load_ramps_data;
%% step 4
A (1,1:4) =[(ramp_R_XYZs(1,11)-XYZk(1));(ramp_G_XYZs(1,11)-XYZk(1));(ramp_B_XYZs(1,11)-XYZk(1)); XYZk(1)]; 
A (2,1:4) =[(ramp_R_XYZs(2,11)-XYZk(2));(ramp_G_XYZs(2,11)-XYZk(2));(ramp_B_XYZs(2,11)-XYZk(2)); XYZk(2)];
A (3,1:4) =[(ramp_R_XYZs(3,11)-XYZk(3));(ramp_G_XYZs(3,11)-XYZk(3));(ramp_B_XYZs(3,11)-XYZk(3)); XYZk(3)];

M_fwd = A./XYZw(2);
%% step 5
% a) start with XYZ for red ramp data set
B = ramp_R_XYZs;
% b) subtract the XYZ values for the black
C = (B-XYZk) ;
% c) normalize the data
D = C/XYZw(2);
D(D<0) = 0;
D(D>1) = 1;
% d) estimate the RGB radiometric scalors
invM = inv(M_fwd(1:3,1:3));
ramp_R_RSs = invM*D;
% e) extract the radiometric scalors from the estimated RSs
ramp_Rr_RSs = ramp_R_RSs(1,:);
% define the 0-255 display values (digital counts) that correspond to ramp values
ramp_DCs = round(linspace(0,255,11));
% f) interpolate the radiometric scalars across the full digital count range to form the forward LUTS
RLUT_fwd = interp1(ramp_DCs,ramp_Rr_RSs(1,:),[0:1:255],'pchip');
% g) repat a-f for the green and blue ramp datasets
% green 
E = ramp_G_XYZs;
F = (E-XYZk);
G = F/XYZw(2);
ramp_G_RSs = invM*G;
ramp_Gr_RSs = ramp_G_RSs(2,:);
GLUT_fwd = interp1(ramp_DCs,ramp_Gr_RSs(1,:),[0:1:255],'pchip');
% blue
H = ramp_B_XYZs;
I = (H-XYZk);
J = I/XYZw(2);
ramp_B_RSs = invM*J;
ramp_Br_RSs = ramp_B_RSs(3,:);
BLUT_fwd = interp1(ramp_DCs,ramp_Br_RSs(1,:),[0:1:255],'pchip');
% h) plot of forward LUTs
figure;
hold on;
x = 0:1:255;
plot(x,RLUT_fwd,'r')
plot(x,GLUT_fwd,'g')
plot(x,BLUT_fwd,'b')
xlabel('digital counts RGB 0-255')
ylabel('radiometric scalars RGB 0-1')
xticks([0:50:250])
yticks([0:.1:1])

%% step 6
M_rev = inv(M_fwd(1:3,1:3));
%% step 7
% a) build the reverse LUT for the red channel
RLUT_rev = uint8(round(interp1(RLUT_fwd, 0:255, linspace(0,max(RLUT_fwd),1024), 'pchip', 0)));

%adapt for green and blue
GLUT_rev = uint8(round(interp1(GLUT_fwd, 0:255, linspace(0,max(GLUT_fwd),1024), 'pchip', 0)));
BLUT_rev = uint8(round(interp1(BLUT_fwd, 0:255, linspace(0,max(BLUT_fwd),1024), 'pchip', 0)));

% b) plot the reverse LUTs
figure;
hold on;
x = 0:1:1023;
plot(x,RLUT_rev, 'r')
plot(x,GLUT_rev, 'g')
plot(x,BLUT_rev, 'b')
xlabel('scaled/quantized radiometric scalars 0-1023')
ylabel('digital counts RGB 0-255')
xticks([0:200:1000])
yticks([0:50:250])
%% step 8
%rename and save display model components
XYZw_disp = XYZw;
XYZk_disp = XYZk;
M_disp = M_rev;
RLUT_disp = RLUT_rev;
GLUT_disp = GLUT_rev;
BLUT_disp = BLUT_rev;

save('display_model.mat','XYZw_disp', 'XYZk_disp','M_disp','RLUT_disp','GLUT_disp','BLUT_disp');
%% step 9
%a) load cie data
cie=loadCIEdata;
XYZ_D50= ref2XYZ(cie.illE,cie.cmf2deg,cie.illD50);
%b)load monkey
load('display_model.mat');
load('munki_CC_XYZs_Labs.txt');
munki_CC_XYZs_Labs = munki_CC_XYZs_Labs';
munki_CC_XYZs = munki_CC_XYZs_Labs(2:4,:);
munki_CC_Labs = munki_CC_XYZs_Labs(5:7,:);
%c)
XYZsdisp = catBradford(munki_CC_XYZs,XYZ_D50',XYZw);
%d) subtract black values
XYZsDisp = XYZsdisp - XYZk_disp;
%e)multiply by M-disp
RGB_RSs =  M_disp * XYZsDisp;
% %f) normalize Radiometric scalars
NRGB_RSs = RGB_RSs/100;
% %g) clips scalars that are less than zero or greater than one
NRGB_RSs(NRGB_RSs<0) = 0;
NRGB_RSs(NRGB_RSs>1) = 1;
% %h)
K = (NRGB_RSs .*1023) + 1;
munki_CC_RSs = round(K);
% %i) 
munki_CC_DCs(:,1) = RLUT_rev(munki_CC_RSs(1,:));
munki_CC_DCs(:,2) = GLUT_rev(munki_CC_RSs(2,:));
munki_CC_DCs(:,3) = BLUT_rev(munki_CC_RSs(3,:));
% %j) 
pix = reshape(munki_CC_DCs,[6 4 3]);
% %k)
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('Colorchecker rendered from measured XYZs and calibrated display model');
%% step 10

%a)
munki_CC_DCs_double = double(munki_CC_DCs .*(100/255));
munki_CC_DCs_double = munki_CC_DCs_double';
munki_CC_DCs_integers = uint8(munki_CC_DCs_double);

%b)
table4til(:,1)= (1:30);
table4til(1:24,2:4) = (munki_CC_DCs_integers (1:3,:)');
table4til (25:27,2:4) = zeros;
table4til(28:30,2:4) = 100.;

%e)
disp_XYZs = importdata('disp_model_test.ti3',' ',20);

%f)
DISP1_XYZs = disp_XYZs.data(1:24,5:7);
DISP_XYZs = DISP1_XYZs';
disp_w = disp_XYZs.data(28:30,5:7);
disp_k = disp_XYZs.data(25:27,5:7);
disp_w_avg = mean(disp_w);
disp_k_avg = mean(disp_k);

%g)
disp_CC_lab = XYZ2Lab(DISP_XYZs,XYZw);

%h)
CD_real_CC = deltaEab(munki_CC_Labs,disp_CC_lab);

%i)
CD_real_CC_min = min(CD_real_CC);
CD_real_CC_max = max(CD_real_CC);
CD_real_CC_mean = mean(CD_real_CC);

%j)
print_display_model_error(munki_CC_Labs,disp_CC_lab,CD_real_CC)

%% step 11
%<include>XYZ2dispRGB.m</include>
%function disp_RGBs = XYZ2dispRGB(display_model,XYZs,XYZn)
% 
% load(display_model)
% 
% XYZsdisp = catBradford(XYZs,XYZn,XYZw_disp);
% 
% newXYZs = XYZsdisp - XYZk_disp;
% 
% RGB_RSs =  M_disp * newXYZs
% 
% n_RSs = RGB_RSs/100
% 
% n_RSs(n_RSs<0) = 0;
% n_RSs(n_RSs>1) = 1;
% 
% K = (n_RSs .* 1023) + 1;
% munki_CC_RSs = round(K);
%  
% munki_CC_DCs(:,1) = RLUT_disp(munki_CC_RSs(1,:));
% munki_CC_DCs(:,2) = GLUT_disp(munki_CC_RSs(2,:));
% munki_CC_DCs(:,3) = BLUT_disp(munki_CC_RSs(3,:));
%  
% pix = reshape(munki_CC_DCs,[6 4 3]);
% 
% pix = imrotate(pix, -90);
% pix = flipdim(pix,2);
% figure;
% image(pix);
% title('Colorchecker rendered from measured XYZs and calibrated display model');
disp_RGBs = XYZ2dispRGB('display_model.mat',munki_CC_XYZs,XYZ_D50');

%% Step 12
%Ethan completed steps 1-4, Ken completed steps 5-9, and the last two steps
%were completed in the lab together. The only porblem we ran into was for
%some reason our matrix dimensions kept getting messed up, so we ended up
%having to tranpose them more than we probably needed to.
