% function [ave,se]=mean_se(r)
% r should be (no.of samples, no. of variables)
function [ave,se]=mean_se(r,aveStr)
if nargin<2
    aveStr='mean';
end
if size(r,1)==1;r=r(:);end
    
if strcmp(aveStr,'mean')
ave=mean(r);
elseif strcmp(aveStr,'median')
    ave=median(r);
end
se=std(r)/sqrt(size(r,1));