%% Ethan Poole and Kennith Ritchings Lab 3 Report
%% init
clear all; close all; clc;
cie= loadCIEdata;


%% loadCIEdata
% <include>loadCIEdata.m</include>

%% Blackbody and illumunant graph

% blackbody graph

bb2856= blackbody(2856,cie.lambda');
bb5003= blackbody(5003,cie.lambda');
bb5604= blackbody(5604,cie.lambda');

plot(cie.lambda',bb2856,'k');
hold on;
plot(cie.lambda',bb5003,'r');
plot(cie.lambda',bb5604,'b');
plot(cie.lambda',cie.illA./100,'k--');
plot(cie.lambda',cie.illD50./100,'r--');
plot(cie.lambda',cie.illD65./100,'b--');

title('Blackbody and standard Illuminant spectra');
xlabel('wavelength(nm)');
ylabel('Relative Power');
legend('blackbody(2856)','blackbody(5003)','blackbody(5604)','illuminant A','illuminant D50','illuminantD65','location','northwest');

%illuminant graph

x5= cie.cmf2deg (:,1);
y5= cie.cmf2deg (:,2);
z5= cie.cmf2deg (:,3);
x10= cie.cmf10deg (:,1);
y10= cie.cmf10deg (:,2);
z10= cie.cmf10deg (:,3);

figure;

plot(x5, 'r');
hold on;
plot(y5, 'g');
plot(z5, 'b');
plot(x10, '--r');
plot(y10, '--g');
plot(z10, '--b');

title('CIE standard observers CMF''s');
xlabel('wavelength (nm)');
ylabel('relative power');
legend('x-bar 2 deg','y-bar 2 deg','z-bar 2 deg','x-bar 2 deg','x-bar 10 deg','y-bar 10 deg','z-bar 10 deg''location','best');
 

%% equation calculating xyz tristimulous values
% <include>ref2XYZ.m</include>


%% Step 5
%test for reflectance spectra on color checker chart



CC_spectra = importdata('ColorChecker_380_780_5nm.txt');
for patch_num = 2:25    
    CC_XYZs(:,patch_num-1) = ref2XYZ(CC_spectra(:,patch_num),cie.cmf2deg,cie.illD65);
end
CC_XYZs

    


%% Step 6
% <include>XYZ2xyY.m</include>

%% Step 7

CC_xyYs= XYZ2xyY(CC_XYZs)

%% Step 8
% create tristimulous values for the chromaticity coordinates

cm_lams = 380:10:730;
cm_h_offset = 19;

data = importdata ('5.1_real.sp', ' ', cm_h_offset);
real_51 = data.data/100;
data = importdata ('5.1_matched.sp', ' ', cm_h_offset);
matched_51 = data.data/100;
data = importdata ('5.1_imaged.sp', ' ', cm_h_offset);
imaged_51 = data.data/100;

data = importdata ('5.2_real.sp', ' ', cm_h_offset);
real_52 = data.data/100;
data = importdata ('5.2_matched.sp', ' ', cm_h_offset);
matched_52 = data.data/100;
data = importdata ('5.2_imaged.sp', ' ', cm_h_offset);
imaged_52 = data.data/100;


%% Step 9a
%patch 5.1 measured and interpolated spectra graph

real1int = interp1(cm_lams, real_51, cie.lambda, 'linear', 'extrap');
imaged1int = interp1(cm_lams, imaged_51, cie.lambda, 'linear', 'extrap');
matched1int = interp1(cm_lams, matched_51, cie.lambda, 'linear', 'extrap');

figure;
hold on
title('patch 5.1 measured and interpolated spectra');
xlabel('wavelength(nm)');
ylabel('reflectance factor');
plot(cm_lams, real_51, 'ro');
plot(cm_lams, imaged_51, 'go');
plot(cm_lams, matched_51, 'bo');
plot(cie.lambda, real1int, 'k.');
plot(cie.lambda, imaged1int, 'k.');
plot(cie.lambda, matched1int, 'k.');
legend('real measured', 'imaged measured', 'matched measured', 'real interpolatied', 'imaged interpolated', 'matched interpolated', 'Location', 'northeast');
hold off;
ylim([0 1]);

%% Step 9b
%patch 5.2 measured and interpolated spectra graph
real2int = interp1(cm_lams, real_52, cie.lambda, 'linear', 'extrap');
imaged2int = interp1(cm_lams, imaged_52, cie.lambda, 'linear', 'extrap');
matched2int = interp1(cm_lams, matched_52, cie.lambda, 'linear', 'extrap');

figure;
hold on;
title('patch 5.2 measured and interpolated spectra');
xlabel('wavelength(nm)');
ylabel('reflectance factor');
plot(cm_lams, real_52, 'ro');
plot(cm_lams, imaged_52, 'go');
plot(cm_lams, matched_52, 'bo');
plot(cie.lambda, real2int, 'k.');
plot(cie.lambda, imaged2int, 'k.');
plot(cie.lambda, matched2int, 'k.');
legend('real measured', 'imaged measured', 'matched measured', 'real interpolatied', 'imaged interpolated', 'matched interpolated', 'Location', 'northeast');
hold off;
ylim([0 1]);


%% step 10
%import data from lab 2 and using results print tables

real= importdata ('5.2_XYZ_Labs_real.txt');
imaged= importdata ('5.2_XYZ_Labs_imaged');
matched=importdata ('5.2_XYZ_Labs_matched');
real1 = ref2XYZ(real1int(:),cie.cmf2deg,cie.illD50);
imaged1 = ref2XYZ(imaged1int(:),cie.cmf2deg,cie.illD50);
matched1 = ref2XYZ(matched1int(:),cie.cmf2deg,cie.illD50);
real2 = ref2XYZ(real2int(:),cie.cmf2deg,cie.illD50);
imaged2 = ref2XYZ(imaged2int(:),cie.cmf2deg,cie.illD50);
matched2 = ref2XYZ(matched2int(:),cie.cmf2deg,cie.illD50);

%% step 10a
%tables for compairing color patch data to measured patch 1

fprintf('\t\t\t\t\tPatch5.1\n')
fprintf('\t\t\tmeasured\t\t\tcalculated\n')
fprintf('\t\t X \t\t y \t\t z \t\t x  \t\t y \t\t z\n')
fprintf('\t real')
fprintf('\t %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f', real.data(1,2:4), real1)
fprintf('\n\t imaged')
fprintf('\t %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f', imaged.data(1,2:4), imaged1)
fprintf('\n\t matched')
fprintf('\t %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f', matched.data(1,2:4), matched1)

%% step 10b
%tables for compairing color patch data to measured patch 2
fprintf('\t\t\t\t\tPatch5.2\n')
fprintf('\t\t\tmeasured\t\t\tcalculated\n')
fprintf('\t\t X \t\t y \t\t z \t\t x  \t\t y \t\t z\n')
fprintf('\t real')
fprintf('\t %7.4f', real.data(1,2:4), real2)
fprintf('\n\t imaged')
fprintf('\t %7.4f', imaged.data(1,2:4), imaged2)
fprintf('\n\t matched')
fprintf('\t %7.4f', matched.data(1,2:4), matched2)

%% step 11a
% calculating xyY values

realc_xyY = XYZ2xyY(real1);
imagedc_xyY = XYZ2xyY(imaged1);
matchedc_xyY = XYZ2xyY(matched1);
realc2_xyY = XYZ2xyY(real2);
imagedc2_xyY = XYZ2xyY(imaged2);
matchedc2_xyY = XYZ2xyY(matched2);
realm1_xyY = XYZ2xyY(real.data);
imagedm1_xyY = XYZ2xyY(imaged.data);
matchedm1_xyY = XYZ2xyY(matched.data);
realm2_xyY = XYZ2xyY(real.data);
imagedm2_xyY = XYZ2xyY(imaged.data);
matchedm2_xyY = XYZ2xyY(matched.data);

%% turn the XYZ values into tables

fprintf('\t\t\\tt\tPatch5.1\n')
fprintf('\t\t\tmeasured\t\t\tcalculated\n')
fprintf('\t\t X \t\t y \t\t Y \t\t x \t\t y \t\t Y n')
fprintf('\t real')
fprintf('\t %7.4f', realm1_xyY', realc_xyY')
fprintf('\n\t imaged')
fprintf('\t %7.4f', imagedm1_xyY', imagedc_xyY')
fprintf('\n\t matched')
fprintf('\t %7.4f', matchedm1_xyY', matchedc_xyY')

fprintf('\t\t\\tt\tPatch5.2\n')
fprintf('\t\t\tmeasured\t\t\tcalculated\n')
fprintf('\t\t X \t\t y \t\t Y \t\t x \t\t y \t\t Y n')
fprintf('\t real')
fprintf('\t %7.4f', realm2_xyY', realc2_xyY')
fprintf('\n\t imaged')
fprintf('\t %7.4f', imagedm2_xyY', imagedc2_xyY')
fprintf('\n\t matched')
fprintf('\t %7.4f', matchedm2_xyY', matchedc2_xyY')

%% step 12
%visualization of calculated patched values on the the chromaticity diagram

plot_chrom_diag_skel;
title('chromaticity coordinates for patches 5.1 and 5.2')
sz = 15;
real1 = scatter(realc_xyY(1),realc_xyY(2), sz,'s','r');
real2 = scatter(realc2_xyY(1),realc2_xyY(2), sz,'s','b');
imaged1 = scatter(imagedc_xyY(1),imagedc_xyY(2), sz,'d','r');
imaged2 = scatter(imagedc2_xyY(1),imagedc2_xyY(2), sz,'d','b');
matched1 = scatter(matchedc_xyY(1),matchedc_xyY(2), sz,'+','r');
matched2 = scatter(matchedc2_xyY(1),matchedc2_xyY(2), sz,'+','b');
legend([real1,imaged1,matched1,real2,imaged2,matched2],{'5.1 real','5.1 imaged','5.1 matched','5.2 real','5.2 imaged', '5.2 matched'})