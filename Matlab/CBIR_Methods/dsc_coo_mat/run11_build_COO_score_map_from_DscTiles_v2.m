close all;
clear all;

fidxTrain='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
wdirQ='..';
wdirTrain=fileparts(fidxTrain);

tdata=readtable(fidxTrain);
lstId=tdata.id;

lstPath=importdata(fidx);
numPath=numel(lstPath);
% % numPath=10;

dscType='COO';
lstNumQ=[16];
numQ=numel(lstNumQ);
isLSQ=true;
numK=20;


for qq=1:numQ
    tnumQ=lstNumQ(qq);
    strParamCOO=sprintf('p2q(%d)[1,3,5]',tnumQ);
    for ii=1:numPath
        fnTif=lstPath{ii};
        fnTifBase=fnTif(1:end-4);
        fnTifMsk=[fnTifBase,'_MskCksS256.png'];
        %
        timgMsk=imread(fnTifMsk);
        sizMsk=size(timgMsk);
        %
        dirTiles=sprintf('%s_MaskTiles',fnTifBase);
        tfidxTiles=sprintf('%s/idx-tiles.txt', dirTiles);
        tilesInfo=readtable(tfidxTiles);
        lstIndex=sub2ind(sizMsk,tilesInfo.row+1, tilesInfo.col+1);
        %
        tfDscOut=sprintf('%s-DSC-%s-%s.csv', tfidxTiles, dscType, strParamCOO);
        tfDscTrain=sprintf('%s/dsc_%s_%s.csv', wdirTrain, dscType, strParamCOO);
        arrDsc=csvread(tfDscOut);
        arrDscTrain=csvread(tfDscTrain);
        %
        if isLSQ
            arrDsc=sqrt(arrDsc);
            arrDscTrain=sqrt(arrDscTrain);
            dst=pdist2(arrDsc, arrDscTrain,'euclidean');
        else
            dst=pdist2(arrDsc, arrDscTrain,'cityblock');
        end
        %
        lstIdK=repmat(lstId,1,numK);
        [BB,II] = sort(dst,2);
        gidx=II(:,1:numK);
        retCls=lstIdK(gidx);
        retDst=sum(BB(:,1:numK),2)/numK;
        retClsSum=sum(retCls,2);
        retClsProb=retClsSum/numK;
        %
        fnOutProbDst=sprintf('%s_%s_%s_LSQ%d_k%d-ProbDst.csv',tfidxTiles,dscType,strParamCOO,isLSQ,numK);
        tilesInfo.prob=retClsProb;
        tilesInfo.dist=retDst;
        writetable(tilesInfo, fnOutProbDst);
        disp(dirTiles);
    end
end
