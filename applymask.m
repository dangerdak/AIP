%x-coordinates of the vertices of central bloom
xbloom = [1454 1454 1743 1743 998 998 1421 1421];
%y-coordinates of the vertices of central bloom
ybloom = [4518 572 572 101 101 572 572 4518];
bloommask = imcomplement(poly2mask(xbloom,ybloom, 4611, 2570));
% 
% %x-coordinates of the noisy border
% xbord = [1 2570 2570 1 1 116 116 2477 2477 1];
% %y-coordinates of the noisy border
% ybord = [4611 4611 1 1 4518 4518 101 101 4518 4518];
% bordermask = imcomplement(poly2mask(xbord,ybord, 4611, 2570));

%mask for the large star
r = 616;
c = [1424, 3212];
t = linspace(0,2*pi,360); 
largecircmask = imcomplement(poly2mask(r*cos(t)+c(1),r*sin(t)+c(2),4611,2570));

%masks for smaller stars
r1 = 109;
c1 = [780, 3309];
star1mask = imcomplement(poly2mask(r1*cos(t)+c1(1),r1*sin(t)+c1(2),4611,2570));

r2 = 68;
c2 = [977, 2770];
star2mask = imcomplement(poly2mask(r2*cos(t)+c2(1),r2*sin(t)+c2(2),4611,2570));

r3 = 68;
c3 = [906, 2291];
star3mask = imcomplement(poly2mask(r3*cos(t)+c3(1),r3*sin(t)+c3(2),4611,2570));

r4 = 50;
c4 = [2136, 3754];
star4mask = imcomplement(poly2mask(r4*cos(t)+c4(1),r4*sin(t)+c4(2),4611,2570));

imagefilter = im < 50000;

%combination of all masks
masktotal= bloommask.*largecircmask.*star1mask.*star2mask.*star3mask.*star4mask.*imagefilter;

%mosaic must be read into variable "im"
maskedim = immultiply(masktotal,im);

%crop noisy edges of image
rect = [206 211 2270 4214];
readyim = imcrop(maskedim, rect);

fitswrite(readyim, 'readymosaic.fits');

