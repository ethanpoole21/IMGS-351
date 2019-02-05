%% project 7 Ethan Poole Kenneth Ritchings
%

%% init
clear all;
clc;
cie=loadCIEdata;
XYZ_D50= ref2XYZ(cie.illE,cie.cmf2deg,cie.illD50);
XYZ_D65= ref2XYZ(cie.illE,cie.cmf2deg,cie.illD65);
%% step 1
%a
load('camera_RGBs.mat')
%b
camera_double = double(camera_RGBs .* (100/255));
camera_uint8 = uint8(camera_double);
%c
table4ti1 = zeros(30,4);
table4ti1(:,1) = 1:30;
table4ti1(1:24,2:4) = camera_uint8(1:3,:)';
table4ti1(28:30,2:4) = 100;
%d
%Save the result as ?workflow_test_uncal.ti1?.
%e
%Use the ColorMunki and the Argyll command ?dispread -P 1,0,2 -v workflow_test_uncal?
%f
uncal_XYZs = importdata('workflow_test_uncal.ti3',' ',20);
%g
uncal_XYZs = uncal_XYZs.data;
uncal_CC_XYZ = uncal_XYZs(1:24,5:7);
uncal_CC_XYZ1 = uncal_CC_XYZ';

uncal_k = uncal_XYZs(25:27,5:7);
uncal_w = uncal_XYZs(28:30,5:7);

XYZk = mean(uncal_k)';
XYZw = mean(uncal_w)';
%h
uncal_CC_lab = XYZ2Lab (uncal_CC_XYZ1,XYZw);
%i
load('munki_CC_XYZs_Labs.txt');
real = munki_CC_XYZs_Labs(1:24,5:7);
%j
real1 = real';
delta = deltaEab(real1, uncal_CC_lab);
delta_min = min(delta);
delta_max = max(delta);
delta_mean = mean(delta);
%k

uncal_CC_lab1 = uncal_CC_lab';

print_uncalibrated_workflow_error(real1,uncal_CC_lab,delta)

%% step 2
%a
load('camera_RGBs.mat');
%b
cam_XYZs = camRGB2XYZ('cam_model.mat',camera_RGBs);
%c
cam_rgbs = XYZ2dispRGB('display_model.mat',cam_XYZs,XYZ_D50);
%d
cam_double = double(cam_rgbs .* (100/255));
cam_double1 = cam_double';
cam_unit8 = uint8(cam_double1);
%e
Table4ti1 = zeros(30,4);
Table4ti1(:,1) = 1:30;
Table4ti1(1:24,2:4) = cam_unit8(1:3,:)';
Table4ti1(28:30,2:4) = 100;
% f
%Save the result as ?workflow_test_cal.ti1?.
%g
%Use the ColorMunki and the Argyll command ?dispread -P 1,0,2 -v workflow_test_uncal?
%h
cal_XYZs = importdata('workflow_test_cal.ti3',' ',20);
%i
cal_XYZs = cal_XYZs.data;
cal_CC_XYZ = cal_XYZs(1:24,5:7);
cal_CC_XYZ1 = cal_CC_XYZ';

cal_k1 = uncal_XYZs(25:27,5:7);
cal_w1 = uncal_XYZs(28:30,5:7);

XYZk1 = mean(cal_k1)';
XYZw1 = mean(cal_w1)';
%j
cal_CC_lab = XYZ2Lab (cal_CC_XYZ1,XYZw1);
%k
load ('munki_CC_XYZs_Labs.txt')
REAL = munki_CC_XYZs_Labs(1:24,5:7);
%l
REAL1 = REAL';
Delta = deltaEab(REAL1, cal_CC_lab);
delta_min = min(Delta);
delta_max = max(Delta);
delta_mean = mean(Delta);
%m
cal_CC_lab1 = cal_CC_lab';

print_uncalibrated_workflow_error(REAL1,cal_CC_lab,Delta)
%% step 3
%a
img_orig = imread('color_chart.jpg');
%a2
[r,c,p] = size(img_orig);
pix_orig = reshape(img_orig,[r*c,p])';
PIX_orig = double(pix_orig);
%a3
pix_XYZ = camRGB2XYZ('cam_model.mat',PIX_orig);
pix_DCs_calib = XYZ2dispRGB('display_model.mat',pix_XYZ,XYZ_D50);
%a4
img_calib = reshape(pix_DCs_calib, [r,c,p]);
%b
imwrite(img_calib,'calib.jpg');
%c
imshow(img_calib)
%% step 4
% download colormunki application and create profile using colormunki
%% step 5
%select created profile
%% step 6
% download and install the appropriate driver for the Epson 1430 printer
%% step 7
% use the ICC printer profile provided in the project resources
%% step 8
% Use a color-managed image viewer to open the color-calibrated image of the 
%CC chart you produced in step 3
%% step 9
%make a print of the color-calibrated image using the ICC color management system
%% step 10a
chart_diaplay = imread('chart_display.jpg');
imshow('chart_display.jpg')
%% step 10b
print_diaplay = imread('print_display.jpg');
imshow('print_display.jpg')

%% feedback section
% we completed the entire project together
% problems we faced include that when printing the greys did not represent
% the colors displayed
% we had to go back and recreate display model, measured RGB values and
% camera model values multiple times to get the best image we could
% we thought that this entire project was a good way to wrap up the course