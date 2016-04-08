function [ ret ] = plot_fpca_filters_color( lst_fpca )
%PLOT_FPCA_FILTERS Summary of this function goes here
%   Detailed explanation goes here
    p_num=numel(lst_fpca);
    if p_num>64
        p_num=64;
    end
    rnum=floor(sqrt(p_num));
    if mod(p_num, rnum)==0
        cnum=floor(p_num/rnum);
    else
        cnum=floor(p_num/rnum)+1;
    end
    figure,
    for ii=1:p_num
% %         tmp=reshape(p_scores(:,ii),siz);
        tmp=lst_fpca{ii};
        if size(tmp,3)==1
            subplot(rnum,cnum, ii), imshow(tmp, []);
        elseif size(tmp,3)==1
            subplot(rnum,cnum, ii), imshow(uint8(tmp));
        else
            tmp=tmp(:,:,1:3);
            tmp=255.*(tmp-min(tmp(:)))/(max(tmp(:))-min(tmp(:)));
            subplot(rnum,cnum, ii), imshow(uint8(tmp));
        end
        title(['#', num2str(ii), ', std=', num2str(std(tmp(:)))]);
    end
    ret=0;
end
