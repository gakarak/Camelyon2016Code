close all;
clear all;

% % fidx='/home/ar/data/Camelyon16_Challenge/Train_Data_for_1stage_segmentation/idx_PINK_L8.txt';
fidx='/home/ar/data/Camelyon16_Challenge/Train_Data_for_1stage_segmentation/idx_BLUE_L8.txt';

fidxData=importdata(fidx);
numImg=numel(fidxData);

fsiz=[11,11];
lstSigma=[3,5];
numSigm=numel(lstSigma);


se = strel('disk',3);

arrDscTumor=[];
arrDscNormal=[];
for ii=1:numImg
    tfn=fidxData{ii};
    tfnBase=tfn(1:end-11);
    tfnEval=[tfnBase,'_EvaluationMask2.png'];
    %
    timg=imread(tfn);
    timgEval=imread(tfnEval);
    timgd=im2double(timg);
% %     timgDsc=reshape(timgd,[],3);
    timgDsc=[];
    for ss=1:numSigm
        tsigm=lstSigma(ss);
        timgf=imfilter(timgd, fspecial('gaussian',fsiz,tsigm));
        if isempty(timgDsc)
            timgDsc=reshape(timgf,[],3);
        else
            timgDsc=[timgDsc, reshape(timgf,[],3)];
        end
    end
    timgEvalDil=imdilate(timgEval,se);
    tevalV=reshape(timgEval,[],1);
    tevalDilV=reshape(timgEvalDil,[],1);
    numTum=sum(tevalV>0);
    %
    tmpArrDscTumor=timgDsc(tevalV>0,:);
    tmpArrDscNormalTot=timgDsc(tevalDilV<1,:);
    %
    tnumNormalTot=size(tmpArrDscNormalTot,1);
    rndIdx=randperm(tnumNormalTot);
    rndIdxCut=rndIdx(1:numTum);
    tmpArrDscNormal=tmpArrDscNormalTot(rndIdxCut,:);
    if isempty(arrDscTumor)
        arrDscTumor=tmpArrDscTumor;
        arrDscNormal=tmpArrDscNormal;
    else
        arrDscTumor=[arrDscTumor; tmpArrDscTumor];
        arrDscNormal=[arrDscNormal; tmpArrDscNormal];
    end
    %
    fprintf('(%d/%d) size=%d --> %s\n', ii,numImg, size(arrDscTumor,1), tfn);
end

%%
lblNormal=zeros(size(arrDscNormal,1),1);
lblTumor=ones(size(arrDscTumor,1),1);

arrDsc=[arrDscNormal; arrDscTumor];
arrLbl=[lblNormal; lblTumor];

arrDscLbl=[arrLbl, arrDsc];

%%
B=mnrfit(arrDsc, categorical(arrLbl));
foutModel=sprintf('%s-MNRFIT-MDL1.csv', fidx);
csvwrite(foutModel,B);
retCls=mnrval(B,arrDsc);

%%
[X,Y,T,AUC] = perfcurve(arrLbl,retCls(:,2),1);
figure,
subplot(1,3,1), plot(X,Y), title(sprintf('AUC=%0.3f',AUC));
grid on;
subplot(1,3,2),
hold all
plot(T),
plot(Y==1),
legend({'T','TP==1'});
hold off
grid on;
subplot(1,3,3), plot(T,Y), title('TP(T)');
grid on

%%
timgCls=mnrval(B,timgDsc);
timgClsTum=reshape(timgCls(:,2),[size(timg,1), size(timg,2)]);
timgClsTum2=uint8(255*repmat(timgClsTum>0.01,1,1,3));
timgClsTum2(:,:,1)=timgEval;


figure,
subplot(1,2,1), imshow(timg)
subplot(1,2,2), imshow(timgClsTum2)

%%
% % mdlKnn=fitcknn(arrDsc,arrLbl,'NumNeighbors',5);
% % [~,retCls]=predict(mdlKnn, arrDsc);
% % 
% % [X,Y,T,AUC] = perfcurve(arrLbl,retCls(:,2),1);
% % figure,
% % subplot(1,2,1), plot(X,Y), title(sprintf('AUC=%0.3f',AUC));
% % grid on;
% % subplot(1,2,2),
% % hold all
% % plot(T),
% % plot(Y==1),
% % legend({'T','TP==1'});
% % hold off
% % grid on;
% % 
% % %%
% % mdlSVM=fitcsvm(arrDsc,arrLbl);
% % [~,retCls]=predict(mdlSVM, arrDsc);

