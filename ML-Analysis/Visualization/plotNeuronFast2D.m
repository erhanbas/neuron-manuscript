function hPlot = plotNeuronFast2D( neuronData,dimSelection)
%plotSwcFast. If you want to plot a subset of branches then simply provide
%the swc data only for that subset as a second input.
% Adjencency matrix.
adj = zeros(size(neuronData,1));
ind = find([neuronData.parentNumber]>0);
adj(sub2ind(size(adj),[neuronData(ind).sampleNumber]',[neuronData(ind).parentNumber]')) = 1;
adj(sub2ind(size(adj),[neuronData(ind).parentNumber]',[neuronData(ind).sampleNumber]')) = 1;
% Plot.
coordinates = [[neuronData.x]',[neuronData.y]',[neuronData.z]'];
[x,y] = gplot(adj, coordinates(:,dimSelection));
hPlot = plot(x,y);
end

