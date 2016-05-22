% This script uses all the Motion Estimation algorithms written for the
% final project and save their results.
% The algorithms being used are Exhaustive Search, Three Step Search, New
% Three Step Search, Simple and Efficient Search, Four Step Search, Diamond
% Search, and Adaptive Rood Pattern Search.
%
%
% Aroh Barjatya
% For DIP ECE 6620 final project Spring 2004

close all
clear all


% the directory and files will be saved based on the image name
% Thus we just change the sequence / image name and the whole analysis is
% done for that particular sequence

imageName = 'caltrain';
mbSize = 16;
p = 7;

for i = 0:30

    imgINumber = i;
    imgPNumber = i+2;

    if imgINumber < 10
        imgIFile = sprintf('./%s/gray/%s00%d.ras',imageName, imageName, imgINumber);
    elseif imgINumber < 100
        imgIFile = sprintf('./%s/gray/%s0%d.ras',imageName, imageName, imgINumber);
    end

    if imgPNumber < 10
        imgPFile = sprintf('./%s/gray/%s00%d.ras',imageName, imageName, imgPNumber);
    elseif imgPNumber < 100
        imgPFile = sprintf('./%s/gray/%s0%d.ras',imageName, imageName, imgPNumber);
    end

    imgI = double(imread(imgIFile));
    imgP = double(imread(imgPFile));
    imgI = imgI(:,1:352);
    imgP = imgP(:,1:352);
    
    % Exhaustive Search
    [motionVect, computations] = motionEstES(imgP,imgI,mbSize,p);
    imgComp = motionComp(imgI, motionVect, mbSize);
    ESpsnr(i+1) = imgPSNR(imgP, imgComp, 255);
    EScomputations(i+1) = computations;

    % Three Step Search
    [motionVect,computations ] = motionEstTSS(imgP,imgI,mbSize,p);
    imgComp = motionComp(imgI, motionVect, mbSize);
    TSSpsnr(i+1) = imgPSNR(imgP, imgComp, 255);
    TSScomputations(i+1) = computations;

    % Simple and Efficient Three Step Search
    [motionVect, computations] = motionEstSESTSS(imgP,imgI,mbSize,p);
    imgComp = motionComp(imgI, motionVect, mbSize);
    SESTSSpsnr(i+1) = imgPSNR(imgP, imgComp, 255);
    SESTSScomputations(i+1) = computations;

    % New Three Step Search
    [motionVect,computations ] = motionEstNTSS(imgP,imgI,mbSize,p);
    imgComp = motionComp(imgI, motionVect, mbSize);
    NTSSpsnr(i+1) = imgPSNR(imgP, imgComp, 255);
    NTSScomputations(i+1) = computations;

    % Four Step Search
    [motionVect, computations] = motionEst4SS(imgP,imgI,mbSize,p);
    imgComp = motionComp(imgI, motionVect, mbSize);
    SS4psnr(i+1) = imgPSNR(imgP, imgComp, 255);
    SS4computations(i+1) = computations;

    % Diamond Search
    [motionVect, computations] = motionEstDS(imgP,imgI,mbSize,p);
    imgComp = motionComp(imgI, motionVect, mbSize);
    DSpsnr(i+1) = imgPSNR(imgP, imgComp, 255);
    DScomputations(i+1) = computations;
    
    % Adaptive Rood Patern Search
    [motionVect, computations] = motionEstARPS(imgP,imgI,mbSize,p);
    imgComp = motionComp(imgI, motionVect, mbSize);
    ARPSpsnr(i+1) = imgPSNR(imgP, imgComp, 255); 
    ARPScomputations(i+1) = computations;


end



save dsplots2 DSpsnr DScomputations ESpsnr EScomputations TSSpsnr ...
      TSScomputations SS4psnr SS4computations NTSSpsnr NTSScomputations ...
       SESTSSpsnr SESTSScomputations ARPSpsnr ARPScomputations