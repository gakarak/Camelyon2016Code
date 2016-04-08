close all;
clear all;

dinp='/media/ar/data6T/data/CAMELYON16_Full_for_Start/Evaluation/EvaluationMasks';
dout='/home/ar/data/Camelyon16_Challenge/check_evaluation/Results';

lstInp=dir([dinp,'/*.png']);
numInp=numel(lstInp);
koef=32;
% % level=5;
for ii=1:numInp
    finp=[dinp,'/',lstInp(ii).name];
    timg=imread(finp);
    CC=bwconncomp(timg);
    SS=regionprops(CC,'Centroid');
    numReg=numel(SS);
    foutCSV=sprintf('%s/%s.csv', dout, finp(end-27:end-19));
    pshift=0.05;
    f=fopen(foutCSV,'w');
    for kk=1:numReg
        tprob = 1.0 - 2*pshift + pshift*randn();
        if tprob<0.1
            tprob=0.1;
        end
        if tprob>1.0
            tprob=1.0;
        end
        tpos=koef*SS(kk).Centroid;
        fwrite(f, sprintf('%0.3f,%d,%d\n',tprob, int32(tpos(1)), int32(tpos(2))) );
    end
    fclose(f);
    disp(finp);
end