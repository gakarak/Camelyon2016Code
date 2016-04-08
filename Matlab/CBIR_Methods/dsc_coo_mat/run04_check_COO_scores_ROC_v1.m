close all;
clear all;

% % fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Genered/dataset-12k-kovalev-2classes/idx.txt';
fidx='/home/ar/data.CAMELYON16_Full_for_Start/CAMELYON16_Dataset_Generated/dataset-12k-kovalev-2classes/idx.txt';
wdirColorMap='../';
wdirOut=fileparts(fidx);

tdata=readtable(fidx);
lstId=tdata.id;
lstPath=tdata.path;
numImg=numel(lstPath);
% % numImg=10;


% % lstTypesDsc={'p2q(8)[1,3,5]d', 'p2q(16)[1,3,5]d'};
% % lstTypesDsc={'p2q(8)[1,3,5]', 'p2q(16)[1,3,5]'};


% % lstTypesDsc={'p2q(16)[1]',...
% %     'p2q(16)[3]', 'p2q(16)[5]',...
% %     'p2q(8)[1,3,5]', 'p2q(8)[1]',...
% %     'p2q(8)[3]', 'p2q(8)[5]'};


lstTypesDsc={'p2q(8)[1,3,5]', 'p2q(16)[1,3,5]'};
numTypes=numel(lstTypesDsc);
lstNumK=[5,10,20,30];
lstIsSQR=[true,false];

cnt=1;
lstLegend={};
figure,
hold all;
grid on;
for kk=lstNumK
    numK=kk;
    for tt=1:numTypes
        for isLSQR=lstIsSQR
            strParamCOO=lstTypesDsc{tt};
            foutDsc=sprintf('%s/dsc_COO_%s.csv', wdirOut, strParamCOO);
            arrDsc= sqrt(csvread(foutDsc));
            if isLSQR
                arrDsc=sqrt(arrDsc);
            end
            %
            lstIdK=repmat(lstId,1,numK);
            lstIdK1=ones(numImg,numK);
            if isLSQR
                dst=pdist2(arrDsc,arrDsc,'euclidean');
            else
                dst=pdist2(arrDsc,arrDsc,'cityblock');
            end
            %
            [BB,II] = sort(dst,2);
            gidx=II(:,2:numK+1);
            retCls=lstIdK(gidx);
            retACC0=sum((retCls==lstIdK),2)/numK;
            retACC1=sum((retCls==lstIdK1),2)/numK;
            retACCR=100*sum(retACC0>=0.5)/numImg;
            %
            tmpDscName=sprintf('COO_%s_LSQ%d_k%d', strParamCOO, isLSQR, numK);
            %
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
end

