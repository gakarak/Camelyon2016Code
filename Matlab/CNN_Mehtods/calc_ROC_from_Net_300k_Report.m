close all;
clear all;


fidxNetBLUE='/home/ar/data.CAMELYON16_Full_for_Start/dataset_BLUE_and_PINK_300k_Results/idx_BLUE_300k.txt-cls.csv';
fidxNetPINK='/home/ar/data.CAMELYON16_Full_for_Start/dataset_BLUE_and_PINK_300k_Results/idx_PINK_300k.txt-cls.csv';
fidxNetPINKS2='/home/ar/data.CAMELYON16_Full_for_Start/dataset_BLUE_and_PINK_300k_Results/idx_PINK_300k.txt-cls-Stage2.csv';

lstIdx={fidxNetPINK, fidxNetPINKS2, fidxNetBLUE};
lstPref={'3D Histech', '3D Histech (S2)', 'Hamamatsu'};
lstLegend={};

figure,
hold all
for kk=1:numel(lstIdx);
    fidxNet = lstIdx{kk};
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

    tmpDscName=['GoogleNet-300k (',lstPref{kk},')'];
    strScore=sprintf('%s, AUC=%0.3f, Score=%0.2f', tmpDscName, AUC, retACCR);

    lstLegend{kk}=strScore;
    %%
    plot(XX,YY, '-', 'LineWidth', 2), title(strScore, 'Interpreter','None');
% %     legend({strScore}, 'Interpreter','None');
    xlim([0,0.003]);
    ylim([0.3,1]);
    xlabel('FP');
    ylabel('TP');
    set(gca,'FontSize',10,'FontWeight','bold');
    grid on
end
hold off;
title('GoggleNet, 300k Tiles with size 256x225, (3D Histech, Hamamatsu)');
AX=legend(lstLegend, 'Interpreter','None');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',14);

