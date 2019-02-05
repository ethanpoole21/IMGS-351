function [cie] = loadCIEdata

cie10deg = load('CIE_10Deg_380-780-5nm.txt');
cie2deg = load('CIE_2Deg_380-780-5nm.txt');
cieeigD = load('CIE_eigD_380-780-5nm.txt');
illA = load('CIE_IllA_380-780-5nm.txt');
illC = load('CIE_IllC_380-780-5nm.txt');
illD50 = load('CIE_IllD50_380-780-5nm.txt');
illD65 = load('CIE_IllD65_380-780-5nm.txt');
illF = load('CIE_IllF_1-12_380-780-5nm.txt');
colorcheck = load('ColorChecker_380_780_5nm.txt');

cie.lambda = cie2deg(:,1)';
cie.cmf2deg= cie2deg(:,2:end);
cie.cmf10deg= cie10deg(:,2:end);
cie.illA= illA(:,2:end);
cie.illC= illC(:,2:end);
cie.illD50= illD50(:,2:end);
cie.illD65= illD65(:,2:end);
cie.illE= ones(81,1);
cie.illF= illF(:,2:end);
cie.eigD= cieeigD(:,2:end);

