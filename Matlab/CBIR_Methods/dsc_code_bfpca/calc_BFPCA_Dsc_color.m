function [ ret, binImg ] = calc_BFPCA_Dsc_color( img, lst_fpca, idx_fpca)
%CALC_BINDSC_FPCA Summary of this function goes here
%   Detailed explanation goes here
% %     assert(ismatrix(img));
    num_idx=length(idx_fpca);
    imgd=double(img);
    binImg=uint8(zeros( [size(imgd,1), size(imgd,2)] ));
    for ii=1:num_idx
        idx=idx_fpca(ii);
        fltImg=sum(imfilter(imgd,lst_fpca{idx}),3);
        binImg=binImg+bitshift(uint8(fltImg>0),8-ii);
    end
    ret=imhist(binImg);
    ret=ret/sum(ret(:));
% %     if ~isempty(msk)
% %         ret=imhist(binImg);
% %     else
% % 	ret=imhist(binImg(msk>0));
% %     end
end
