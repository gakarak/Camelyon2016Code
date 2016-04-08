close all;
clear all;


fidxNet='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/CNN/idx.txt-cls.csv';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';

tdataNet=readtable(fidxNet);
tdata=readtable(fidx);

lstId=tdata.id;
dataProb=tdataNet.prob;

retACC1=dataProb;
retACC1(lstId==0)=1-retACC1(lstId==0);

numImg=numel(lstId);

idxErr=zeros(numImg,1);
for ii=1:numImg
    idxErr(ii)=~strcmp(tdataNet.label{ii},tdataNet.clslalbel{ii});
end
retACC1(idxErr==1)=1-retACC1(idxErr==1);

dataProb2=dataProb;
dataProb2(idxErr==1)=1-dataProb2(idxErr==1);

[XX,YY,TT,AUC]=perfcurve(lstId,retACC1,1);
retACCR=100*sum(dataProb2>=0.5)/numImg;

tmpDscName='GoogleNet';
strScore=sprintf('%s, AUC=%0.3f, Score=%0.2f', tmpDscName, AUC, retACCR);

% % % % % % % % 
figure,
plot(XX,YY), title(strScore, 'Interpreter','None');
legend({strScore}, 'Interpreter','None');
grid on

foutProb=sprintf('%s/prob_GoogleNet_256x256.csv', fileparts(fidx));
csvwrite(foutProb, retACC1);
