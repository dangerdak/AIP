tic
%write column titles to text output file
header = {'X' 'Y' 'SourceIntensity' 'SourceMean' 'LocalMean' 'CalMag' 'Error'};
xlswrite('resultsfixedap2',header,'A1');

%create binary matrix (dimensions 'dim') representing aperture and define
%width of ring
r=6;
rlarge=r+3;
dim=2*rlarge+1;
c=rlarge+1;
t=linspace(0,2*pi,15);
Ap = poly2mask(r*cos(t)+c,r*sin(t)+c,dim,dim);

%create binary matrix representing annular aperture (ring)
LargeAp = poly2mask(rlarge*cos(t)+c,rlarge*sin(t)+c,dim,dim);
AnnAp = LargeAp - Ap;
[rowap colap] = size(AnnAp);

%preallocate memory for source matrix
sourceim=zeros(dim,dim);

%preallocate memory for results martix
results=zeros(7000,7);

%initialise maxval to value above 'while' limit
maxval=5000;
thresh=3450;

%instrumental zeropoint contained in the image metadata
zeropoint = 25.30;

%specify matrix to be analysed and create border of zeros (so sources too
% close to edge will be rejected)
analysedim=readyim;
[m n] = size(analysedim);
binmask=ones(m,n);
binmask((rlarge+1):(m-rlarge),(rlarge+1):(n-rlarge))=0;
binmask=imcomplement(binmask);
analysedim=analysedim.*binmask;

%check which areas are being treated as sources
testim=analysedim;
%allows us to check number of iterations, and output results row by row
i=1;
%check if maxvals below certain point return  any valid data
fin=0;
%loop
while (maxval > thresh)

    %find maxval and it's location
    [maxval idx]=max(analysedim(:));
    [row col]=ind2sub(size(analysedim),idx);
    
    %if max is isolated pixel, set it to background level
    if ((analysedim(row+1,col) < thresh)...
            && (analysedim(row, col+1) < thresh)...
            && (analysedim(row-1,col) < thresh)...
            && (analysedim(row,col-1) < thresh))
        disp('single pixel')
        analysedim(row,col)=thresh;
        disp('removed')
        continue
    end

    %indicies for section of analysedim around source
    col1=(col-rlarge);
    col2=(col+rlarge);
    row1=(row-rlarge);
    row2=(row+rlarge);

    %extract matrix surrounding maximum value, same dimensions as aperture,
    %from inputim
    sourceim = analysedim(row1:row2,col1:col2);

    
    %check dimensions
    [rowsource colsource] = size(sourceim);
    
    if (rowsource ~= rowap) || (colsource ~= colap)
        disp('Unequal dimensions')
        continue
    end
    
    %find info about source
    SourceStats = regionprops(Ap,sourceim,'Area','MeanIntensity','MinIntensity');
    
    %find info about annular aperture
    AnnStats = regionprops(AnnAp,sourceim,'MeanIntensity');

    
    %if aperture contains a zero value (eg overlaps with a previous
    %aperture) set region to zero and find next max
    if SourceStats.MinIntensity==0
        disp('region already contains a zero')
        disp(maxval)
        analysedim(row1:row2,col1:col2)=sourceim.*imcomplement(Ap);
        continue
    end
    
    
    %subtract local background from source intensity
    SourceIntensity = SourceStats.Area*SourceStats.MeanIntensity...
        - (SourceStats.Area*AnnStats.MeanIntensity);
    
    %calculate calibrated magnitude
    calmag=zeropoint-2.5*log10(SourceIntensity);
    
    %WE NEED TO FIND ERRORS!
    error=1;
    
    results(i,:)=[col row SourceIntensity SourceStats.MeanIntensity...
        AnnStats.MeanIntensity calmag error];
    
    %mask maximum just analysed
    analysedim(row1:row2,col1:col2)=sourceim.*imcomplement(Ap);
    testim(row1:row2,col1:col2)=sourceim.*imcomplement(Ap);
    
    i=i+1;
    disp('end of iteration')
    
    if maxval<3460
        fin = fin+1
    end
end

xlswrite('resultsfixedap2', results,'A2');
toc
%write results to excel file, starting from second row
fitswrite(analysedim, 'analysedimagefixedap2.fits');
fitswrite(testim,'test.fits');
