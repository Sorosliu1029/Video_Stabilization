% Computes motion compensated image's PSNR
%
% Input
%   imgP : The original image 
%   imgComp : The compensated image
%   n : the peak value possible of any pixel in the images
%
% Ouput
%   psnr : The motion compensated image's PSNR
%
% Written by Aroh Barjatya

function psnr = imgPSNR(imgP, imgComp, n)

[row col] = size(imgP);

err = 0;

for i = 1:row
    for j = 1:col
        err = err + (imgP(i,j) - imgComp(i,j))^2;
    end
end
mse = err / (row*col);

psnr = 10*log10(n*n/mse);