close all;
clear all;

fidxTrain='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
wdirQ='..';

lstPath=importdata(fidx);
numPath=numel(lstPath);
% % numPath=12;

dscType='COO';
lstNumQ=[16];
numQ=numel(lstNumQ);
isLSQ=true;


for qq=1:numQ
    tnumQ=lstNumQ(qq);
    fQMap=sprintf('%s/cmap_pink_q%d.csv', wdirQ, tnumQ);
    qMap=csvread(fQMap);
    strParamCOO=sprintf('p2q(%d)[1,3,5]',tnumQ);
    tdscParam=getParamsCOO_V2( strParamCOO );
    disp(fQMap);
    for ii=1:numPath
        fnTif=lstPath{ii};
        fnTifBase=fnTif(1:end-4);
        dirTiles=sprintf('%s_MaskTiles',fnTifBase);
        tfidx=sprintf('%s/idx-tiles.txt', dirTiles);
        tfDscOut=sprintf('%s-DSC-%s-%s.csv', tfidx, dscType, strParamCOO);
        if exist(tfDscOut, 'file')==2
            fprintf('DSC-File exist (%s), skip...', tfDscOut);
        else
            tilesInfo=readtable(tfidx);
            numTiles=numel(tilesInfo.filename);
            tmpDsc=calc_COO_PNIGAd_V2(rgb2ind(imread([dirTiles,'/',tilesInfo.filename{1}]), qMap, 'nodither'),  tdscParam);
            arrDsc=zeros(numTiles,numel(tmpDsc));
            parfor tt=1:numTiles
                tfimg=[dirTiles,'/',tilesInfo.filename{tt}];
                timg=imread(tfimg);
                timgQ=rgb2ind(timg, qMap, 'nodither');
                tdsc=calc_COO_PNIGAd_V2(timgQ,  tdscParam);
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
