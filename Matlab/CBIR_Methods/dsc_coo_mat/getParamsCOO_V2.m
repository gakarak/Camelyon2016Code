function [ param ] = getParamsCOO_V2( dscType)
%GETPARAMSCOO Summary of this function goes here
%   Detailed explanation goes here
% %         'type',         'p2i',...
    offsetsNP = {...
        {},...
        {...
            [ -1,1;   0,1;   1,0;   1,1;   ],...
            [ -2,1;   -1,2;   0,2;   1,2;   2,0;   2,1;   ],...
            [ -3,1;   -2,2;   -1,3;   0,3;   1,3;   2,2;   3,0;   3,1;   ],...
            [ -4,1;   -4,2;   -3,2;   -3,3;   -2,3;   -2,4;   -1,4;   0,4;   1,4;   2,3;   2,4;   3,2;   3,3;   4,0;   4,1;   4,2;   ],...
            [ -5,1;   -5,2;   -4,3;   -3,4;   -2,5;   -1,5;   0,5;   1,5;   2,5;   3,4;   4,3;   5,0;   5,1;   5,2;   ],...
            [ -6,1;   -6,2;   -5,3;   -5,4;   -4,4;   -4,5;   -3,5;   -2,6;   -1,6;   0,6;   1,6;   2,6;   3,5;   4,4;   4,5;   5,3;   5,4;   6,0;   6,1;   6,2;   ],...
        },...
        {
            [ 0,1,-1,1;    1,0,0,1;     1,0,1,1;     1,1,0,1],...
            [ 0,2,-2,1;    1,2,-1,2;    2,0,1,2;     2,1,0,2],...
            [-1,3,-3,1;    1,3,-2,2;    2,2,-1,3;    3,1,1,3,],...
            [-2,4,-4,1;   -1,4,-4,1;   -1,4,-4,2;    0,4,-4,2;    0,4,-3,2;    1,4,-3,2;    1,4,-3,3;    2,3,-2,3;    2,3,-2,4;    2,4,-2,3;    2,4,-2,4;   3,2,-1,4;    3,2,0,4;    3,3,-1,4;   4,0,2,3;    4,0,2,4;    4,1,1,4;    4,1,2,4;    4,2,0,4;    4,2,1,4],...
            [-2,5,-5,1;   -1,5,-5,2;    1,5,-4,3;    2,5,-3,4;    3,4,-2,5;    4,3,-1,5;    5,1,2,5;     5,2,1,5]...
        }
    };
    param=struct(...
        'type',         dscType,...
        'nbi',          16,...
        'nbg',          3,...
        'nba',          3,...
        'nump',         2,...
        'isVal',        true,...
        'isRGB',        false,...
        'isQNT',        false,...
        'isGrd',        false,...
        'isAng',        false,...
        'isRotInv',     true,...
        'isRetSparse',  false,...
        'dst',          [1,3],...
        'offsets',      {offsetsNP});
    % parse number of points (IID, IIID, IIIID e.a.):
    param.nump=str2double(param.type(2));
    % check II-type:
    if ~isempty(strfind(param.type,'i'))
        param.isVal = true;
        retReg=regexp(dscType, 'i\([0-9]+\)', 'match');
        if ~isempty(retReg)
            param.nbi = str2double(retReg{1}(3:end-1));
        end
    else
        param.isVal = false;
    end
    % check CC-type:
    if ~isempty(strfind(param.type,'c'))
        param.isRGB = true;
        param.isVal = true;
        retReg=regexp(dscType, 'c\([0-9]+\)', 'match');
        if ~isempty(retReg)
            param.nbi = str2double(retReg{1}(3:end-1));
        end
    else
        param.isRGB = false;
    end
    % check IDX(quantized)-type:
    if ~isempty(strfind(param.type,'q'))
        param.isQNT = true;
        param.isVal = true;
        retReg=regexp(dscType, 'q\([0-9]+\)', 'match');
        if ~isempty(retReg)
            param.nbi = str2double(retReg{1}(3:end-1));
        end
    else
        param.isQNT = false;
    end
% % % Only one type I,C or Q can be used!!!
    % check GG-type:
    if ~isempty(strfind(param.type,'g'))
        param.isGrd = true;
        retReg=regexp(dscType, 'g\([0-9]+\)', 'match');
        if ~isempty(retReg)
            param.nbg = str2double(retReg{1}(3:end-1));
        end
    else
        param.isGrd = false;
    end
    % check A-type:
    if ~isempty(strfind(param.type,'a'))
        param.isAng = true;
        retReg=regexp(dscType, 'a\([0-9]+\)', 'match');
        if ~isempty(retReg)
            param.nba = str2double(retReg{1}(3:end-1));
        end
    else
        param.isAng = false;
    end
    % find dst-parameters:
    retReg = regexp(dscType, '\[[0-9,]+\]', 'match');
    if ~isempty(retReg)
        param.dst=eval(retReg{1});
    end
% % % % % % %
    

end

