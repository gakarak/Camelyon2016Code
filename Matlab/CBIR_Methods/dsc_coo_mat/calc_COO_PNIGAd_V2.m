function [ dscDat, dscIdx, dscSize ] = calc_COO_PNIGAd_V2( img, param )
%calc_COO_PNIGAd Calculate IGA Coocurence matrix descriptor for any number
%of points 
%   for create structure 'param' you can use getParamsCOO(dscType), where
%   dscTye is 'p{N}[iga]', where N - number of points, 'i', 'g', 'a' - type
%   of coocurences: (i)ntencity, (g)radient, (a)ngle respectively
%   for example: 'p2ig', 'p3i', 'p2iga', 'p3a' e.a.
%   You can use string setup for some parameters of coocurence:
%   - number of bins for I, G, A
%   - distances
%   for example:
%   'p2i(8)g(4)a(8)[1,3]' : 2-point coocurence, 8-bin for intencity, 4-bin
%   for gradient, 8-bin for angle value, point-distances: 1,3,5
%   'p3i(16)[1,3,5]' - calculate 3-point descriptor for distance 1,3,5
    imd=im2double(img);
    if (param.isGrd)||(param.isAng)
        fy=fspecial('sobel');
        fx=fy';
        gx=imfilter(imd, fx);
        gy=imfilter(imd, fy);
        gg=sqrt(gx.^2 + gy.^2);
        gxy=cat(3,gx,gy);
        clear gx gy
    end
% % make binned "intensity" image:
    if param.isRGB
        nch=size(img,3);
        if nch==1
            imd=repmat(imd,1,1,3);
        end
        imb=floor(param.nbi*imd);
        imb=(param.nbi^2)*imb(:,:,3)+(param.nbi^1)*imb(:,:,2)+(param.nbi^0)*imb(:,:,1);
        param.nbi=param.nbi^3;
    elseif param.isQNT
        imb=double(img);
    else
        imb=floor(param.nbi*imd);
    end
    imb(imb>(param.nbi-1))=(param.nbi-1);
% % make binned "gradient" image:
    if param.isGrd
        ggb=floor(param.nbg*gg/2);
        ggb(ggb>(param.nbg-1))=(param.nbg-1);
    end
% % precalculate some helper parameters
    sizig=1;
    if param.isVal
        sizig = sizig*param.nbi;
    end
    if param.isGrd
        sizig = sizig*param.nbg;
    end
% % number of bins per point without Angle:
    sizp=sizig^param.nump;
% % total number of bins for angle:
    sizaTot=param.nba^(param.nump-1);
% % total number of bins for descriptor:
    if param.isAng
        sizTot=(sizig^param.nump)*sizaTot;
    else
        sizTot=sizig^param.nump;
    end
% % % % % % % % % % % % % % % % % % %
    dscDat=[];
    dscIdx=[];
    isTypeIandG=(param.isVal)&&(param.isGrd);
    isTypeIorG=(param.isVal)||(param.isGrd);
    numDst=numel(param.dst);
    for ddi=1:numDst
        dd=param.dst(ddi);
        curOffsets=param.offsets{param.nump}{dd};
        numOffsets=size(curOffsets,1);
        numps=param.nump-1;
        catIGA=[];
        for ii=1:numOffsets
            cOffs=curOffsets(ii,:);
            % prepare coo-values for current shift
            if isTypeIorG
                tigm=zeros(size(imb,1), size(imb,2),param.nump);
                if isTypeIandG
                    tigm(:,:,1)=imb*param.nbg + ggb;
                end
                if param.isVal
                    tigm(:,:,1) = imb;
                end
                if param.isGrd
                    tigm(:,:,1) = ggb;
                end
                for pp=1:numps
                    pOffs=-cOffs(2*(pp-1)+1:2*pp);
                    if isTypeIandG
                        imbs=circshift(imb, pOffs);
                        ggbs=circshift(ggb, pOffs);
                        tigm(:,:,pp+1)=imbs*param.nbg + ggbs; % *(sizig^(pp-1));
                    elseif param.isVal
                        imbs=circshift(imb, pOffs);
                        tigm(:,:,pp+1)=imbs;
                    elseif param.isGrd
                        ggbs=circshift(ggb, pOffs);
                        tigm(:,:,pp+1)=ggbs;
                    end
                end
                %
                if param.isRotInv
                    if (param.nump>2) && (param.isAng)
                        [~, IDXA]=sort(tigm(:,:,2:end),3);
                    end
                    tigm=sort(tigm,3);
                end
                tig=tigm(:,:,1);
                for pp=2:param.nump
                   tig=tig+tigm(:,:,pp)*(sizig^(pp-1));
                end
                clear tigm;
            end
            % prepare coo-angles for current shift
            if param.isAng
                aas = calc_cooa_IN(gxy, cOffs, param.nba, param.nump);
                if (param.isRotInv) && (param.nump>2)
                    if isTypeIorG
                        aas = aas(IDXA);
                        clear IDXA;
                    else
                        aas = sort(aas,3);
                    end
                end
                aac=aas(:,:,1);
                for pp=2:size(aac,3)
                   aac = aac + aas(:,:,pp)*(param.nba^(pp-1)); 
                end
            end
            if param.isAng
                if isTypeIorG
                    catIGA=[catIGA; tig*sizaTot + aac];
                else
                    catIGA=[catIGA; aac];
                end
            else
                catIGA=[catIGA; tig];
            end
        end
        if param.isRetSparse
            idx=unique(catIGA);
            dsch=histc(catIGA(:),idx);
            dscDat=[dscDat;dsch];
            dscIdx=[dscIdx; idx*ddi];
        else
            dsch=histc(catIGA(:),0:(sizTot-1));
            dscDat=[dscDat;dsch];
        end
    end
    dscSize=sizTot*numDst;
end

% helper: need for calculate angle-coocurence
function [ ret ] = calc_cooa_IN( gxy, offset, nbin, nump )
    ret=zeros(size(gxy,1),size(gxy,2),nump-1);
    for pp=1:nump-1
        % inverse-shift point coords
        gxys=circshift(gxy, -offset(2*(pp-1)+1:2*pp));
        nrmxy=sqrt(sum(gxys.^2,3).*sum(gxy.^2,3));
        gxyA=sum(gxy.*gxys,3);
        xyNonZero=(nrmxy>0.01);
        gxyA(xyNonZero)=real(acos(gxyA(xyNonZero)./nrmxy(xyNonZero)))/pi;
        nbin2=(nbin-1);
        gxyA=floor(nbin2*gxyA)+1;
        gxyA(~xyNonZero)=0;
        gxyA(gxyA>=nbin2)=nbin2;
        ret(:,:,pp)=gxyA;
    end
end
