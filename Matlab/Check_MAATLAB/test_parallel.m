close all;
clear all;

arrFlt=randn(35,35,16);
numFlt=size(arrFlt,3);

numData=100;
lstData={};
for ii=1:numData
    lstData{ii}=randn(256,256);
end


lstScalar=cell(numData,1);
parfor ii=1:numData
    timg=lstData{ii};
    timgFltSum=zeros(size(timg));
    for jj=1:numFlt
        timgFltSum=timgFltSum+imfilter(timg,arrFlt(:,:,jj));
    end
    lstScalar{ii}=sum(timgFltSum(:));
    fprintf('%d/%d\n', ii,numData);
end
