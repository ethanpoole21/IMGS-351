function cam_XYZs = camRGB2XYZ(cam_model,camera_rgbs)
% takes input your ?cam_model.mat? and ?cam_RGBs? a 3xn vector of camera-captured RGBs0-255 and returns?cam_XYZs? a 3xn vector of model-estimated XYZs
load('cam_model.mat')
load('camera_RGBs.mat');
Camz_rgbs = (camera_rgbs/255);
camereverse_gray_rgbs = (Camz_rgbs (1:3,19:24));
Cam_gray_rgbs = fliplr(camereverse_gray_rgbs);

r = 1; g = 2; b = 3;

cam_RS(r,:) = polyval(cam_polys(r,:),Camz_rgbs(r,:));
cam_RS(g,:) = polyval(cam_polys(g,:),Camz_rgbs(g,:));
cam_RS(b,:) = polyval(cam_polys(b,:),Camz_rgbs(b,:));
cam_RS(cam_RS<0) = 0;
cam_RS(cam_RS>1) = 1;

%cam_RSs= fliplr(cam_RS (1:3,19:24))

RS_RGBs = cam_RS;

RSrs = RS_RGBs(1,:);
RSgs = RS_RGBs(2,:);
RSbs = RS_RGBs(3,:)

RS_RGBs_extd = [RS_RGBs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; ...  
    RSrs.^2;  RSgs.^2; RSbs.^2;  ones(1,size(RS_RGBs,2))];

cam_XYZs = cam_matrix * RS_RGBs_extd;

end