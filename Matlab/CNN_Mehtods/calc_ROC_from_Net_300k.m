close all;
clear all;


fidxNet='/home/ar/data.CAMELYON16_Full_for_Start/dataset_BLUE_and_PINK_300k_Results/idx_BLUE_300k.txt-cls.csv';
% % fidxNet='/home/ar/data.CAMELYON16_Full_for_Start/dataset_BLUE_and_PINK_300k_Results/idx_PINK_300k.txt-cls.csv';


tdataNet=readtable(fidxNet);

lstLabel=categorical(tdataNet.label);
lstLabelCls=categorical(tdataNet.clslalbel);
lstCategory=categorical({'Normal','Tumor'});
catNormal=lstCategory(1);
catTumor =lstCategory(2);

numImg=numel(lstLabel);

arrProb=tdataNet.prob;
arrProbTumor=arrProb;
arrProbTumor(lstLabel==catNormal)=1-arrProbTumor(lstLabel==catNormal);

idxErr=(lstLabel~=lstLabelCls);
arrProbTumor(idxErr==1)=1-arrProbTumor(idxErr==1);

[XX,YY,TT,AUC]=perfcurve(lstLabel,arrProbTumor,catTumor);
retACCR=100*sum( (arrProbTumor>=0.5)==(lstLabel==catTumor))/numImg;

tmpDscName='GoogleNet-300k';
strScore=sprintf('%s, AUC=%0.3f, Score=%0.2f', tmpDscName, AUC, retACCR);

%%
figure,
subplot(1,2,1),
plot(XX,YY), title(strScore, 'Interpreter','None');
legend({strScore}, 'Interpreter','None');
xlim([0,0.01]);
ylim([0.0,1]);
grid on
subplot(1,2,2),
hold all
plot(TT,YY)
plot(TT,XX)
hold off
legend({'TP(T)', 'FP(T)'});
grid on



