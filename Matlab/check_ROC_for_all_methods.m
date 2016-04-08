close all;
clear all;

wdir='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';

tdataTable=readtable(fidx);
lstId=tdataTable.id;


lstTypes={'BFPCA', 'COO', 'GoogleNet', 'HIST'};
lstLineTypes={'-','--','o-',':'};
numTypes=numel(lstTypes);

maxNumBest=5;


lstBestTypes={};
lstBestTypesLineStyle={};
lstBestROC={};
lstBestScores={};
cnt=1;
for ii=1:numTypes
    tType=lstTypes{ii};
    tTypeLine=lstLineTypes{ii};
    lstFn=dir([wdir,'/prob_',tType,'*.csv']);
    numFn=numel(lstFn);
    lstPaths={};
    for jj=1:numFn
        lstPaths{jj}=sprintf('%s/%s', wdir, lstFn(jj).name);
    end
    %
    arrScore=zeros(numFn,2);
    lstROC={};
    for jj=1:numFn
        tpath=lstPaths{jj};
        tdata=csvread(tpath);
        numImg=numel(tdata);
        [XX,YY,TT,AUC]=perfcurve(lstId,tdata,1);
        retACCR=100*sum( (tdata>=0.5)==lstId )/numImg;
        arrScore(jj,1)=AUC;
        arrScore(jj,2)=retACCR;
        lstROC{jj}=[XX,YY];
    end
    [BB,II]=sort(-arrScore(:,1));
    maxIdx=maxNumBest;
    if numFn<maxNumBest
        maxIdx=numFn;
    end
    arrIISorted=II(1:maxIdx);
    for jj=1:maxIdx
        tidxSrt=arrIISorted(jj);
        lstBestROC{cnt}=lstROC{tidxSrt};
        [~,fname,~]=fileparts(lstPaths{tidxSrt});
        lstBestTypes{cnt}=fname;
        lstBestScores{cnt}=arrScore(tidxSrt,:);
        lstBestTypesLineStyle{cnt}=tTypeLine;
        cnt=cnt+1;
    end
    disp(numFn);
end

%%
numBestROC=numel(lstBestROC);
figure,
hold all;
lstLegend={};
for ii=1:numBestROC
    tXY=lstBestROC{ii};
    tTypeLine=lstBestTypesLineStyle{ii};
    tSCR=lstBestScores{ii};
    tType=lstBestTypes{ii};
    tLegend=sprintf('%s, AUC=%0.3f, Score=%0.2f', tType, tSCR(1), tSCR(2));
    lstLegend{ii}=tLegend;
    plot(tXY(:,1), tXY(:,2),tTypeLine,'LineWidth',2);
end
xlim([0.0, 0.01]);
ylim([0.1, 1.0]);
hold off;
grid on;
legend(lstLegend, 'Interpreter','None');
