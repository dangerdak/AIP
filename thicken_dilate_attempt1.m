% for thicken/dilate attempt - to remove isolated pixels
% grayimim=mat2gray(croppedim);
% binthresh=(thresh/(max(croppedim(:)));
% binim=im2bw(grayim, binthresh);
% readyim=bwmorph(

%find background as mode of original image, and subtract from prepared
%image
% background = mode(im(:));
% wobackground = imsubtract(readyim,background);
% wobackground(wobackground<0)=0;

thresh =3450;
%convert to grayscale and then binary, using threshold "thresh"
grayim=mat2gray(readyim);
binthresh=thresh/(max(readyim(:)));
binim1=im2bw(grayim,binthresh);
%remove isolated pixels
binim=bwmorph(binim1,'clean');

%find & label "connected components" ie sources in image binim, and label
%them
CC=bwconncomp(binim,8);
L=labelmatrix(CC);

findmaxbox;
%maxbox(1)=#rows of AnnAp matrix and maxbox(2)=#cols

%get info about each labeled region in L
SourceStats=regionprops(L,readyim,'Area','MinIntensity','MaxIntensity','Centroid','MeanIntensity');

%find size of image
[m n]=size(readyim);
%Preallocate size of matrices to increase efficiency
number_of_outputs=7;
results = zeros(CC.NumObjects,number_of_outputs);
binim_large = zeros(m,n);
binim_edge = zeros(m,n);
binim_ann = zeros(m,n);
L = zeros(m,n);

%Width ann ap
AnnWidth = 3;


%extend object "AnnWidth" pixels to find area surrounding source (without
%joining of disconnected 1s('thicken') or disconnecting object borders
%(by not subtracting edge pixels of source)
binim_large = bwmorph(L,'thicken',AnnWidth);
%remove centre of source to find edge
binim_edge = bwmorph(L,'remove');
%don't subtract edges from binim_large
binim_ann = binim_large - (L - binim_edge);

AnnStats = regionprops(binim_ann,readyim,'MeanIntensity','BoundingBox');

%Bounding boxes contains ul_corner and width
BoundingBoxes=[AnnStats.BoundingBox];
%round up any non integers
BoundingBoxes=ceil(BoundingBoxes);

for 
    
     
       
        


%Intsrumental zeropoint
zeropoint = 25.30;

tic
%Loop through sources
for source=1:5 %CC.NumObjects


    
    %subtract local background to find source intensity
    sourcetotal = SourceStats(source).Area*...
        SourceStats(source).MeanIntensity - SourceStats(source).Area*...
        AnnStats.MeanIntensity;
    
    %use intrumental zero point to calculate calibrated magnitude
    calmag = zeropoint -2.5*log10(sourcetotal);
    
    %write data to array 'results': x,y,total,calmag,source area,
    %mean source intensity, mean background intensity
    results(source,:) = [SourceStats(source).Centroid(1) SourceStats(source).Centroid(2) sourcetotal calmag SourceStats(source).Area SourceStats(source).MeanIntensity AnnStats.MeanIntensity]; 
end

%output results outside of for loop for efficiency
    %create file to which data will be written
% catalogue = fopen('catalogue.csv','w');
% fprintf(catalogue,'%12s %12s \r\n','sourcetotal','cal mag','source Area','MeanInt Source','MeanInt Local Back';
% catalogue = fopen('catalogue.csv','a');
%     fprintf(catalogue,'%12.8f \r\n',results);
%     fclose(catalogue);

%or output results matrix to ascii (comma separated by default)
dlmwrite('catalogue.ascii',results);
toc
