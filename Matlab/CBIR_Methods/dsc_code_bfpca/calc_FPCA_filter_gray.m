function [ ret ] = calc_FPCA_filter_gray( lst_img, nsamplesPerImage, siz, sigm, npca )
%CALC_FPCA_FILTER_LIST 
%   calc_FPCA_filter_list( lst_img, nsamplesPerImage, siz, sigm, npca )
    num_img=length(lst_img);
    assert(num_img>0);
    isPath=ischar(lst_img{1});
    nsiz=siz(1)*siz(2);
    data=[];
    for ii=1:num_img
        if isPath
            img=imread(lst_img{ii});
        else
            img=lst_img{ii};
        end
        if ~ismatrix(img)
            img=rgb2gray(img);
        end
        gimg=double(img);
        tmpData=zeros(nsamplesPerImage, nsiz);
        idxDiap=size(gimg)-siz-1;
        rs=randi(idxDiap(1),[nsamplesPerImage,1]);
        cs=randi(idxDiap(2),[nsamplesPerImage,1]);
        gkern=fspecial('gaussian', siz, sigm);
        cnt=1;
        for kk=1:nsamplesPerImage
            tmp =gimg(rs(kk):rs(kk)+siz(1)-1, cs(kk):cs(kk)+siz(2)-1);
            tmp =tmp.*gkern;
            tmpn=(tmp-mean(tmp(:)))/std(tmp(:));
            tmpn=tmp;
% %             tmpn=tmpn.*gkern;
            tmpData(cnt,:)=reshape(tmpn, [],1); cnt=cnt+1;
        end
        data=[data;tmpData];
    end
% %     [p_scores,p_coefs,p_variances] = pca(data);
    [p_scores,~,~] = pca(data);
    cnt=1;
    for ii=1:npca
        tmp=p_scores(:,ii);
% %             tmp=p_scores(ii,:);
% %         if abs(sum(tmp))<0.0000001
            ret{cnt}=reshape(tmp,siz)-mean(tmp(:));
            cnt=cnt+1;
% %         end
    end
end
