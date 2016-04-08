close all;
clear all;

wdir='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';

tdataTable=readtable(fidx);
lstId=tdataTable.id;


lstTypes={'BFPCA', 'COO', 'GoogleNet', 'HIST'};
% % lstTypes={'HIST'};
lstLineTypes={'-','--','o-',':'};
numTypes=numel(lstTypes);

maxNumBest=10;


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
        if (XX(2)==0)
            [~,tmpDscTypeZFP,~]=fileparts(tpath);
            fprintf('XX(2)=%0.5f, YY(2)=%0.2f, FP==0: %d [%s]\n', XX(2), YY(2), (XX(2)==0), tmpDscTypeZFP);
            lstBestROC{cnt}=[XX,YY];
            [~,fname,~]=fileparts(tpath);
            lstBestTypes{cnt}=fname;
            lstBestScores{cnt}=[AUC, retACCR, YY(2)];
            lstBestTypesLineStyle{cnt}=tTypeLine;
            cnt=cnt+1;
        end
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
    tLegend=sprintf('%s, AUC=%0.3f, Score=%0.2f, TF(Zero-FP)=%0.2f', tType, tSCR(1), tSCR(2), tSCR(3));
    lstLegend{ii}=tLegend;
    plot(tXY(:,1), tXY(:,2),tTypeLine,'LineWidth',2);
end
xlim([0.0, 0.01]);
ylim([0.1, 1.0]);
hold off;
grid on;
xlabel('FP');
ylabel('TP');
legend(lstLegend, 'Interpreter','None');
