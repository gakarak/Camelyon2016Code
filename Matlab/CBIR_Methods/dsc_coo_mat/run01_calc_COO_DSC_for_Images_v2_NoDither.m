close all;
clear all;

% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-12k-kovalev-2classes/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
wdirColorMap='../';
wdirOut=fileparts(fidx);

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);
% % numImg=10;


% % lstNumQ=[8,16,32,64,128,256,512];
lstNumQ=[8,16];
numNumQ=numel(lstNumQ);

for qq=1:numNumQ
    tnumQ=lstNumQ(qq);
    fQMap=sprintf('%s/cmap_pink_q%d.csv', wdirColorMap, tnumQ);
    qMap=csvread(fQMap);
    strParamCOO=sprintf('p2q(%d)[1,3,5]',tnumQ);
    tdscParam=getParamsCOO_V2( strParamCOO );
    disp(fQMap);
    %
    tmpDsc=calc_COO_PNIGAd_V2(rgb2ind(imread(lstPath{1}), qMap, 'nodither'),  tdscParam);
    arrDsc=zeros(numImg,numel(tmpDsc));
    %
    parfor ii=1:numImg
        timg=imread(lstPath{ii});
        timgQ=rgb2ind(timg, qMap, 'nodither');
        tdsc=calc_COO_PNIGAd_V2(timgQ,  tdscParam);
        arrDsc(ii,:)=tdsc/sum(tdsc(:));
        if mod(ii,100)==0
            fprintf('#Q=%d, %d/%d\n', tnumQ, ii, numImg);
        end
    end
    foutDsc=sprintf('%s/dsc_COO_%s.csv', wdirOut, strParamCOO);
    csvwrite(foutDsc, arrDsc);
end

