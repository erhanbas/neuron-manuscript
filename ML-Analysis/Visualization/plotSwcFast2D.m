function hPlot = plotSwcFast2D( swcData,dimSelection,conSwc )
%plotSwcFast. If you want to plot a subset of branches then simply provide
%the swc data only for that subset as a second input.
if nargin<3
    conSwc = swcData;
end
% Adjencency matrix.
adj = zeros(max(conSwc(:,1)));
ind = find(conSwc(:,7)>0);
adj(sub2ind(size(adj),conSwc(ind,1),conSwc(ind,7))) = 1;
adj(sub2ind(size(adj),conSwc(ind,7),conSwc(ind,1))) = 1;
% Plot.
dimSelection = dimSelection+2;
[x,y] = gplot(adj, swcData(:,dimSelection));
hPlot = plot(x,y);
end

