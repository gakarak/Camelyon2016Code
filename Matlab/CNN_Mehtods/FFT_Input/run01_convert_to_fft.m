close all;
clear all;


fidxInp='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
wdirOut='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes_fft';


idxInp=readtable(fidxInp);

numImg=numel(idxInp.path);
numSamples=1000;
rndIdx=randperm(numImg);
rndIdx=rndIdx(1:numSamples);

% % for ii=1:numImg
meanImgFFT=[];
for ii=rndIdx
    tfimg=idxInp.path{ii};
    timg=imread(tfimg);
    timgFFT=log(fftshift(abs(fft2(double(timg)))));
    if isempty(meanImgFFT)
        meanImgFFT=timgFFT;
    else
        meanImgFFT=meanImgFFT+timgFFT;
    end
    if mod(ii,50)==0
        disp(ii);
    end
end

%%
meanImgFFT=meanImgFFT/numel(rndIdx);
meanImgFFT(meanImgFFT<0)=0;
imshow(meanImgFFT(:,:),[]);
qMinMax=quantile(meanImgFFT(:),[0.01,0.99]);
qmin=qMinMax(1);
qmax=qMinMax(2);
%%
for ii=1:numImg
    tfimg=idxInp.path{ii};
    timg=imread(tfimg);
    timgFFT=log(fftshift(abs(fft2(double(timg)))));
    timgFFT=uint8(255*(timgFFT-qmin)/(qmax-qmin));
    [q1,q2,q3]=fileparts(tfimg);
    [~,dirId,~]=fileparts(q1);
    tdirOut=[wdirOut,'/',dirId];
    if ~isdir(tdirOut)
        mkdir(tdirOut);
    end
    fimgOut=[tdirOut,'/',q2,'.png'];
    imwrite(timgFFT, fimgOut);
    if mod(ii,100)==0
        fprintf('%d/%d\n',ii,numImg);
    end
% %     imshow(timgFFT);
% %     drawnow;
end

