close all;
clear all;


fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
fnProb='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/prob_HIST_q512_LSQ1_k20.csv';

tdataTable=readtable(fidx);
lstId=tdataTable.id;

numImg=numel(lstId);
tdata=csvread(fnProb);

retACCR=100*sum( (tdata>=0.5)==lstId )/numImg;

[XX,YY,TT,AUC]=perfcurve(lstId,tdata,1);

[~,tType,~]=fileparts(fnProb);

strTitle=sprintf('%s, AUC=%0.3f, Score=%0.2f, TP(Zero-FP)=%0.2f', tType, AUC, retACCR, YY(2));

figure,
subplot(1,2,1),
plot(XX,YY), title(strTitle, 'Interpreter', 'None');
xlim([0,0.01]);
grid on
subplot(1,2,2),
hold all
plot(TT,XX)
plot(TT,YY)
hold off
legend({'FP(T)', 'TP(T)'})
grid on
