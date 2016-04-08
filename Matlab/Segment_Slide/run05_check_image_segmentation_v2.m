close all;
clear all;

% % fidx='/home/ar/data/Camelyon16_Challenge/Train_Data_for_1stage_segmentation/idx_PINK_L8.txt';
% % fidx='/home/ar/data/Camelyon16_Challenge/Train_Data_for_1stage_segmentation/idx_BLUE_L8.txt';

% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK_L8.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_BLUE_L8.txt';

fidxData=importdata(fidx);
numImg=numel(fidxData);


foutModel=sprintf('%s-MNRFIT-MDL1.csv', fidx);
mdlB=csvread(foutModel);



fsiz=[11,11];
lstSigma=[3,5];
numSigm=numel(lstSigma);

se = strel('disk',1);
probT=0.7;

arrDscTumor=[];
arrDscNormal=[];
arrScore=zeros(numImg,1);
figure,
for ii=1:numImg
    tfn=fidxData{ii};
    tfnBase=tfn(1:end-11);
    tfnEval=[tfnBase,'_EvaluationMask2.png'];
    %
    timg=imread(tfn);
    timgEval=imread(tfnEval);
    timgd=im2double(timg);
% %     timgDsc=reshape(timgd,[],3);
    timgDsc=[];
    for ss=1:numSigm
        tsigm=lstSigma(ss);
        timgf=imfilter(timgd, fspecial('gaussian',fsiz,tsigm));
        if isempty(timgDsc)
            timgDsc=reshape(timgf,[],3);
        else
            timgDsc=[timgDsc, reshape(timgf,[],3)];
        end
    end
    %
    timgCls=mnrval(mdlB,timgDsc);
    timgClsTum=reshape(timgCls(:,2),[size(timg,1), size(timg,2)]);
    timgClsTum2=uint8(255*repmat(timgClsTum>probT,1,1,3));
    timgClsTum2(:,:,1)=timgEval;
    timgClsTumMsk=imdilate((timgClsTum>probT),se);
    %
    tmp=(timgClsTumMsk>0)&(timgEval>0);
    tScore=100*sum(tmp(:))/sum(sum(timgEval>0));
    arrScore(ii)=tScore;
    %
    fnOutMskClsS128=sprintf('%s_MskCksS128.png',tfnBase);
    imwrite(timgClsTumMsk, fnOutMskClsS128);
    fnOutMskClsS256=sprintf('%s_MskCksS256.png',tfnBase);
    sizS256=size(timgClsTumMsk)/2;
    timgClsTumMskS256=uint8(255*(imresize(timgClsTumMsk, sizS256)>0));
    imwrite(timgClsTumMskS256, fnOutMskClsS256);
    %
    subplot(1,3,1), imshow(imfilter(timg, fspecial('gaussian',fsiz,3)));
    subplot(1,3,2), imshow(timgClsTum2);
    subplot(1,3,3), imshow(timgClsTumMsk);
    drawnow;
% %     pause(1);
    fprintf('(%d/%d) --> %s\n', ii,numImg, tfn);
end

%%
figure, 
plot(arrScore), title('Score in %');
ylim([0,100]);
grid on;
