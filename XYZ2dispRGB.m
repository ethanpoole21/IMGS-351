function disp_RGBs = XYZ2dispRGB(display_model,XYZs,XYZn)

load(display_model)

XYZsdisp = catBradford(XYZs,XYZn,XYZw_disp);

newXYZs = XYZsdisp - XYZk_disp;

RGB_RSs =  M_disp * newXYZs;

n_RSs = RGB_RSs/100;

n_RSs(n_RSs<0) = 0;
n_RSs(n_RSs>1) = 1;

K = (n_RSs .* 1023) + 1;
munki_CC_RSs = round(K);
 
munki_CC_DCs(:,1) = RLUT_disp(munki_CC_RSs(1,:));
munki_CC_DCs(:,2) = GLUT_disp(munki_CC_RSs(2,:));
munki_CC_DCs(:,3) = BLUT_disp(munki_CC_RSs(3,:));
disp_RGBs = munki_CC_DCs;

