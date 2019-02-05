%% lab 5 Ethan Ken
%% init

clear all;
close all;
clc;

cie=loadCIEdata;

XYZ_D50= ref2XYZ(cie.illE,cie.cmf2deg,cie.illD50);
XYZ_D65= ref2XYZ(cie.illE,cie.cmf2deg,cie.illD65);

%% step 1
%download and unpack project 5 zip folder
%% step 2
%take high quality images of cropped color checker chart
uncropped_image = imread('uncropped_colorchecker.jpg');
imshow ('uncropped_colorchecker.jpg');

cropped_image = imread('cropped_colorchecker.jpg');
imshow ('cropped_colorchecker.jpg');

%% step 3
%step 3a 
load('camera_RGBs.mat');
%step 3b

Camera_rgbs = (camera_RGBs/255);

%step 3c

camereverse_gray_rgbs = (Camera_rgbs (1:3,19:24));

%step 3d

Camera_gray_rgbs = fliplr(camereverse_gray_rgbs);

%% step 4
%step 4a
munki_CC_XYZs_Labs.txt=importdata('munki_CC_XYZs_Labs.txt');
a= (munki_CC_XYZs_Labs.txt (:,2:4));
b= (munki_CC_XYZs_Labs.txt (:,5:7));
munki_XYZs = transpose(a);
munki_Labs = transpose(b);
%step4b-d
c= (munki_XYZs (2,19:24));
d= flip(c);
munki_gray_Ys = d/100;
%% step 5

x1 = Camera_gray_rgbs (1,:);
x2 = Camera_gray_rgbs (2,:);
x3 = Camera_gray_rgbs(3,:);
y1 = munki_gray_Ys (1,:);
y2 = munki_gray_Ys (1,:);
y3 = munki_gray_Ys (1,:);

figure
plot(y1,x1,'r',y2,x2,'g',y3,x3,'b')

xlabel('munki grey Ys')
ylabel('camera grey RGBS')
title('original grayscale Y to RGB relationship')

%% step 6


r = 1; g = 2; b = 3;


% a) fit low-order polynomial functions between normalized

% camera-captured gray RGBs and the munki-measured gray Ys
cam_polys(r,:)=polyfit(Camera_gray_rgbs(r,:),munki_gray_Ys,3);
cam_polys(g,:)=polyfit(Camera_gray_rgbs(g,:),munki_gray_Ys,3);
cam_polys(b,:)=polyfit(Camera_gray_rgbs(b,:),munki_gray_Ys,3);

% b) use the functions to linearize the camera data
cam_RSs(r,:) = polyval(cam_polys(r,:),Camera_rgbs(r,:));
cam_RSs(g,:) = polyval(cam_polys(g,:),Camera_rgbs(g,:));
cam_RSs(b,:) = polyval(cam_polys(b,:),Camera_rgbs(b,:));

% c) clip out of range values
cam_RSs(cam_RSs<0) = 0;
cam_RSs(cam_RSs>1) = 1;

cam_rss= fliplr(cam_RSs (1:3,19:24))
%% step 7
% print table that visualized the data in step 6
z1 = cam_rss (1,:)
z2 = cam_rss (2,:)
z3 = cam_rss(3,:)
c1 = munki_gray_Ys (1,:)
c2 = munki_gray_Ys (1,:)
c3 = munki_gray_Ys (1,:)

figure
plot(c1,z1,'r',c2,z2,'g',c3,z3,'b')

xlabel('munki grey Ys(radiometric scalars)')
ylabel('camera grey RGBS')
title('original grayscale Y to RGB relationship')

%% step 8
% visualization of the impact of the pre and post linearalization 

% visualize the original camera RGBs
pix = permute(Camera_rgbs, [3 2 1]);
pix = reshape(pix, [6 4 3]);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('original camera patch RGBs');

% visualize the linearized camera RGBs
pix = permute(cam_RSs, [3 2 1]);
pix = reshape(pix, [6 4 3]);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('linearized camera patch RGBs');

%% step 9
cam_matrix3x3 = munki_XYZs * pinv(cam_RSs)

%<include>cam_matrix3x3<include>
%% step 10
cam_XYZs = cam_matrix3x3 * cam_RSs
%% step 11
% a) use XYZ2lab function to change values

cam_labs = XYZ2Lab(cam_XYZs,XYZ_D50)

% b) use delta Eab color differences between these estimated Lab values and the measured Lab values

dEab_colordiff = deltaEab(cam_labs,munki_Labs)

% c) call the print_camera_model_table function to visualize the data

print_camera_model_table(munki_Labs,cam_labs,dEab_colordiff)

%% step 12
% split the radiometric scalars (cam_RSs) into r,g,b vectors

RSrgbs = cam_RSs;
RSrs = RSrgbs(1,:);
RSgs = RSrgbs(2,:);
RSbs = RSrgbs(3,:)

% create vectors of these RSs with multiplicative terms 

RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; ...  
    RSrs.^2;  RSgs.^2; RSbs.^2;  ones(1,size(RSrgbs,2))];

% find the extended (3x11) matrix that relates the RS and XYZ datasets

cam_matrix = munki_XYZs * pinv(RSrgbs_extd)

%% step 13
% estimate XYZs from the RSs using the extended matrix and RS representation

RScam_XYZs = cam_matrix * RSrgbs_extd;

%% step 14
% a) use your XYZ2Lab function to calculate Lab values from the XYZ values
% you estimated in step 13

RSlab = XYZ2Lab(RScam_XYZs,XYZ_D50)

% b) calculate ?E color differences between these estimated Lab values and the measured Lab values

DEablabs = deltaEab(RSlab,cam_labs)

% c) print a table

print_extended_camera_model_error(munki_Labs,cam_labs,DEablabs)

%% step 15
% save the (extended) camera model for use in later projects
save('cam_model.mat', 'cam_polys', 'cam_matrix');
%% step 16
%%test the camrgb2xyz function

cam_XYZs = camRGB2XYZ('cam_model.mat',camera_RGBs)


%function cam_XYZs = camRGB2XYZ(cam_model,camera_rgbs)
% takes input your ?cam_model.mat? and ?cam_RGBs? a 3xn vector of camera-captured RGBs0-255 and returns?cam_XYZs? a 3xn vector of model-estimated XYZs
%load('cam_model.mat')
%load('camera_RGBs.mat');
% Camz_rgbs = (camera_rgbs/255);
% camereverse_gray_rgbs = (Camz_rgbs (1:3,19:24));
% Cam_gray_rgbs = fliplr(camereverse_gray_rgbs);
% 
% r = 1; g = 2; b = 3;
% 
% cam_RS(r,:) = polyval(cam_polys(r,:),Camz_rgbs(r,:));
% cam_RS(g,:) = polyval(cam_polys(g,:),Camz_rgbs(g,:));
% cam_RS(b,:) = polyval(cam_polys(b,:),Camz_rgbs(b,:));
% cam_RS(cam_RS<0) = 0;
% cam_RS(cam_RS>1) = 1;
% 
% %cam_RSs= fliplr(cam_RS (1:3,19:24))
% 
% RS_RGBs = cam_RS;
% 
% RSrs = RS_RGBs(1,:);
% RSgs = RS_RGBs(2,:);
% RSbs = RS_RGBs(3,:)
% 
% RS_RGBs_extd = [RS_RGBs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; ...  
%     RSrs.^2;  RSgs.^2; RSbs.^2;  ones(1,size(RS_RGBs,2))];
% 
% cam_XYZs = cam_matrix * RS_RGBs_extd;


%% step 17
%visualize if camera model and and camRGB2XYZ function are working correctly

% visualize the munki-measured XYZs as an sRGB image
munki_XYZs_D65 = catBradford(munki_XYZs, XYZ_D50, XYZ_D65);
munki_XYZs_sRGBs = XYZ2sRGB(munki_XYZs_D65);
pix = reshape(munki_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('munki XYZs chromatically adapted and visualized in sRGB');


% visualize the camera-estimated XYZs as an sRGB image
cam_XYZs_D65 = catBradford(cam_XYZs, XYZ_D50, XYZ_D65);
cam_XYZs_sRGBs = XYZ2sRGB(cam_XYZs_D65);
pix = reshape(cam_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('estimated XYZs chromatically adapted and visualized in sRGB');
