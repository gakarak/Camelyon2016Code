close all;
clear all;


% % fidx='/home/ar/data/Camelyon16_Challenge/dataset-500-shuf-2classes2/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-500-shuf-2classes2/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';

% % fidx='/home/ar/data/Camelyon16_Challenge_Dataset_PINK/idx.txt';
% % parType='PINK';
fidx='/home/ar/data/Camelyon16_Challenge_Dataset_BLUE/idx.txt';
parType='BLUE';

% % tdata=importdata(fidx,',');
tdata=readtable(fidx);

lstId=tdata.id;
lstPath=tdata.path;

numImg=numel(lstId);

numImgForSet=20000;
rndIdx=randperm(numImg);
rndIdx=rndIdx(1:numImgForSet);

numSmplPerImg=120;
arrRGB=[];
for ii=1:numImgForSet
    timg=imread(lstPath{rndIdx(ii)});
    timgr=reshape(timg,[],3);
    tsiz=size(timgr,1);
    trndIdx=randperm(tsiz);
    tarr=timgr(trndIdx,:);
    arrRGB=[arrRGB; tarr(1:numSmplPerImg,:)];
    if mod(ii,100)==0
        fprintf('%d/%d\n', ii,numImgForSet);
    end
end

%%
sizSQR=floor(sqrt(size(arrRGB,1)));
timgRnd=reshape(arrRGB(1:sizSQR*sizSQR,:),sizSQR,sizSQR,3);
figure,
subplot(1,2,1), imshow(timgRnd);
drawnow;
%%
lstNumQ=[8,16,32,64,128,256,512,1024];
numNumQ=numel(lstNumQ);
for ii=1:numNumQ
    tnum=lstNumQ(ii);
    [XX,map]=rgb2ind(timgRnd,tnum);
    tfout=sprintf('cmap_%s_q%d.csv', parType,tnum);
    csvwrite(tfout, map);
    subplot(1,2,2), imshow(XX,map), title(sprintf('#map = %d',tnum));
    pause(1);
    drawnow;
end
