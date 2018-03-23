function [swcGT,connGT,swcTest,connTest] = X_G(GTswc,testswc)
[swcData] = loadSWC(GTswc);
% edges
nE = size(swcData,1);
edges = swcData(:,[1 7]);
edges(any(edges==-1,2),:) = [];
if isempty(edges)
    E=[];
else
    E = sparse(edges(:,1),edges(:,2),1,nE,nE);
end
swcGT = swcData;
connGT = max(E,E');

[swcData] = loadSWC(testswc);
% edges
nE = size(swcData,1);
edges = swcData(:,[1 7]);
edges(any(edges==-1,2),:) = [];
if isempty(edges)
    E=[];
else
    E = sparse(edges(:,1),edges(:,2),1,nE,nE);
end
swcTest = swcData;
connTest = max(E,E');