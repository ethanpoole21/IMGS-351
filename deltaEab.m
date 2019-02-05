function DEab = deltaEab(Lab1, Lab2)
L1 = Lab1(1,:);
a1 = Lab1(2,:);
b1 = Lab1(3,:);
L2 = Lab2(1,:);
a2 = Lab2(2,:);
b2 = Lab2(3,:);

DEab = sqrt((L2-L1).^2+(a2-a1).^2+(b2-b1).^2);