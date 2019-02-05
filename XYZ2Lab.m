function Lab = XYZ2Lab(XYZ, XYZn)
rats = XYZ./XYZn;

f_rats=rats.^(1/3);
indx = find(rats<=0.008856);
f_rats(indx) = 7.787*rats(indx) + 16/116;

Lab = [116*f_rats(2,:)-16;500*(f_rats(1,:)-f_rats(2,:));200*(f_rats(2,:)-f_rats(3,:))];
end