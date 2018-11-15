function D2 = jacDist(ZI,ZJ)
%jacDist. Called by pdist function in heatmapClustering.
% must have form:
%ZI is a 1-by-n vector containing a single observation.
%
%ZJ is an m2-by-n matrix containing multiple observations. 
%distfun must accept a matrix XJ with an arbitrary number of observations.
% D2 is an m2-by-1 vector
nNeurons = size(ZJ,1);
D2 = NaN(nNeurons,1);
for iNeuron = 1:nNeurons
    % select only positive pixels
    ZA = ZI>0;
    ZB = ZJ(iNeuron,:)>0;
    ind = ZA | ZB;
    ZA = ZA(ind); ZB = ZB(ind);
    % get jaccard distance.
    D2(iNeuron) = sum(ZA&ZB)/sum(ZA|ZB);
end
end

