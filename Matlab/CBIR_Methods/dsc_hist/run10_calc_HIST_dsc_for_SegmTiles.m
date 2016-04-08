close all;
clear all;

fidxTrain='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Normal/idx_PINK.txt';
wdirQ='..';

lstPath=importdata(fidx);
% % numPath=numel(lstPath);
numPath=5;

dscType='HIST';
lstNumQ=[256,512];
numQ=numel(lstNumQ);
isLSQ=true;


for qq=1:numQ
    tnumQ=lstNumQ(qq);
    fQMap=sprintf('%s/cmap_pink_q%d.csv', wdirQ, tnumQ);
    qMap=csvread(fQMap);
    disp(fQMap);
    for ii=1:numPath
        fnTif=lstPath{ii};
        fnTifBase=fnTif(1:end-4);
        dirTiles=sprintf('%s_MaskTiles',fnTifBase);
        tfidx=sprintf('%s/idx-tiles.txt', dirTiles);
        tfDscOut=sprintf('%s-DSC-%s-q%d.csv', tfidx, dscType, tnumQ);
        if exist(tfDscOut, 'file')==2
            fprintf('DSC-File exist (%s), skip...', tfDscOut);
        else
            tilesInfo=readtable(tfidx);
            numTiles=numel(tilesInfo.filename);
            arrDsc=zeros(numTiles,tnumQ);
            parfor tt=1:numTiles
                tfimg=[dirTiles,'/',tilesInfo.filename{tt}];
                timg=imread(tfimg);
                timgQ=rgb2ind(timg, qMap, 'nodither');
                tdsc=histc(timgQ(:), 1:tnumQ);
                arrDsc(tt,:)=tdsc/sum(tdsc(:));
                if mod(tt,100)==0
                    fprintf('[%d/%d] : [%d/%d], #Q=%d\n', ii, numPath, tt, numTiles,tnumQ);
                end
            end
            csvwrite(tfDscOut, arrDsc);
        end
        disp(dirTiles);
    end
end
