function featDists = getPdDist(recons,type)
if nargin==1
    type=[];
end
numneurons = length(recons);
featsDist=[];
for i=1:numneurons
    [featsDist{i},keynodes] = getKeyPd(recons{i}.recon,type);
    if i==1
        figure(100)
        gplot3(recons{i}.recon.A,recons{i}.recon.subs)
        hold on
        myplot3(recons{i}.recon.subs(keynodes,:),'o')
    end
end

dists=[featsDist{:}];
[hits,edges] = histcounts(dists,'BinMethod','fd');
centers = (edges(1:end-1) + edges(2:end))/2;
figure,bar(centers,hits);
featDists = zeros(numneurons,length(centers));
for i=1:numneurons
    [featDists(i,:)] = histcounts(featsDist{i},edges);
end