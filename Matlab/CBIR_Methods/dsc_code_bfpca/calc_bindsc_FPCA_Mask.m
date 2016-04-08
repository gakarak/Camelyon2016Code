function [ ret ] = calc_bindsc_FPCA_Mask( img, msk, lst_fpca, idx_fpca)
%CALC_BINDSC_FPCA Summary of this function goes here
%   Detailed explanation goes here
    assert(ismatrix(img));
    num_idx=length(idx_fpca);
    gimg=double(img);
    binImg=uint8(zeros(size(gimg)));
    for ii=1:num_idx
        idx=idx_fpca(ii);
        fltImg=imfilter(img,lst_fpca{idx});
        binImg=binImg+bitshift(uint8(fltImg>0),8-ii);
    end
    if ~isempty(msk)
        ret=imhist(binImg);
    else
	ret=imhist(binImg(msk>0));
    end
end
