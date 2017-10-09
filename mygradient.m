function [mag,ori] = mygradient(I)

%
% compute image gradient magnitude and orientation at each pixel
%

F = [-1 1];
F2 = [-1; 1];

dx = imfilter(I, F);
dy = imfilter(I, F2);

mag = sqrt(dx.^2 + dy.^2);

ori = atan(dy./dx);

