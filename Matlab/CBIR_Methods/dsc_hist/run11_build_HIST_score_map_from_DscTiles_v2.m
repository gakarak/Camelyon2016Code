close all;
clear all;

fidxTrain='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Tumor/idx_PINK.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/Train_Normal/idx_PINK.txt';
wdirQ='..';
wdirTrain=fileparts(fidxTrain);

tdata=readtable(fidxTrain);
lstId=tdata.id;

lstPath=importdata(fidx);
% % numPath=numel(lstPath);
numPath=5;

dscType='HIST';
lstNumQ=[512];
numQ=numel(lstNumQ);
isLSQ=true;

listNumK=[100];
numNumK=numel(listNumK);

for kk=1:numNumK
    numK=listNumK(kk);
    for qq=1:numQ
        tnumQ=lstNumQ(qq);
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
            tfDscOut=sprintf('%s-DSC-%s-q%d.csv', tfidxTiles, dscType, tnumQ);
            tfDscTrain=sprintf('%s/dsc_hist_q%d.csv', wdirTrain, tnumQ);
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
            fnOutProbDst=sprintf('%s_%s_q%d_LSQ%d_k%d-ProbDst.csv',tfidxTiles,dscType,tnumQ,isLSQ,numK);
            tilesInfo.prob=retClsProb;
            tilesInfo.dist=retDst;
            writetable(tilesInfo, fnOutProbDst);
            disp(dirTiles);
        end
    end
end
