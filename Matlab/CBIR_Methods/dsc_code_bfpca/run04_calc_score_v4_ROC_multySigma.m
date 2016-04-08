close all;
clear all;

% % fidx='/home/ar/data/Camelyon16_Challenge/dataset-500-shuf-2classes2/idx.txt';
% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-500-shuf-2classes2/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
fltBank='fltbank-camelion2016-rgb.dat';

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);
% % numImg=20;

% % % % % % % % % % % % % % % % % % % 
lstFltBank=fun_read_fpca_filterbank(fltBank);
sizeBank=numel(lstFltBank);

% % % % % % % % % % % % % % % % % % % 
lstIdxFltSigm={2,3,4};
arrDsc0=[];
numDscTypes=numel(lstIdxFltSigm);

for tt=1:numDscTypes
    tidxFltSigm=lstIdxFltSigm{tt};
    foutDscCSV=sprintf('%s/dsc_bfpca_s%d.csv',fileparts(fidx), tidxFltSigm);
    tarrDsc=csvread(foutDscCSV);
	%
    if isempty(arrDsc0)
        arrDsc0=tarrDsc;
    else
        arrDsc0=[arrDsc0, tarrDsc];
    end
end

dscIdx=sprintf('BFPCA_s%s',strrep(mat2str(cell2mat(lstIdxFltSigm)),' ','-'));

lstNumK=[5,10,20,30];
lstIsSQR=[true,false];

numDscTypes=numel(lstIdxFltSigm);
numNumK=numel(lstNumK);

wdirOut=fileparts(fidx);
lstResults={};
cnt=1;
lstLegend={};
figure,
hold all;
for kk=lstNumK
    numK=kk;
    for isLSQR=lstIsSQR
        if isLSQR
            arrDsc=sqrt(arrDsc0);
        else
            arrDsc=arrDsc0;
        end
        %
        lstIdK=repmat(lstId,1,numK);
        lstIdK1=ones(numImg,numK);
        if isLSQR
            dst=pdist2(arrDsc0,arrDsc0,'euclidean');
        else
            dst=pdist2(arrDsc0,arrDsc0,'cityblock');
        end
        [BB,II] = sort(dst,2);
        gidx=II(:,2:numK+1);
        retCls=lstIdK(gidx);
        retACC0=sum((retCls==lstIdK),2)/numK;
        retACC1=sum((retCls==lstIdK1),2)/numK;
        %
        retACCR=100*sum(retACC0>=0.5)/numImg;
% %         foutROC_XY=sprintf('%s/rocxy_BFPCA_%s_LQ%1.csv', wdirOut, tidxFltSigm, isLSQR);
        tmpDscName=sprintf('%s_LSQ%d_k%d', dscIdx, isLSQR, numK);
        foutPROB=sprintf('%s/prob_%s.csv', wdirOut, tmpDscName);
        fprintf('save --> (%s)\n', foutPROB);
        csvwrite(foutPROB, retACC1);
        [XX,YY,TT,AUC]=perfcurve(lstId,retACC1,1);

        fprintf('Acc (%s): %0.2f %%\n', tmpDscName, retACCR);
        %
        lstLegend{cnt}=sprintf('%s, AUC=%0.3f, Score=%0.2f', tmpDscName, AUC, retACCR);
        plot(XX,YY),title(lstLegend{cnt}, 'Interpreter','None');
        legend(lstLegend, 'Interpreter','None');
        drawnow;
        %
        cnt=cnt+1;
    end
end

