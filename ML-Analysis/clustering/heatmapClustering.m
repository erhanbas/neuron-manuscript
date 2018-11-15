function [] = heatmapClustering(resultFolder, cellInfoFile, anaMask,varargin)
%heatmapClustering. Clusters cells based on heatmaps.
%% Parse input.
p = inputParser;
p.addRequired('resultFolder',@(x) ischar(x));
p.addRequired('cellInfoFile',@(x) ischar(x));
p.addRequired('anaMask',@(x) ischar(x));
p.addParameter('DistanceFunction','jacDist',@(x) ischar(x));
p.addParameter('MdsCriterion','metricstress',@(x)any(strcmpi(x,{'stress','sstress','metricstress','metricsstress','sammon','strain'})) );
p.addParameter('LinkageMethod','complete',@(x) any(strcmpi(x,{'average','complete','centroid','median','single','ward','weighted'})));
p.addParameter('Cutoff',1,@(x) isnumeric(x));
p.parse(resultFolder, cellInfoFile, anaMask, varargin{:});
Inputs = p.Results;
clear resultFolder cellNames anaMask

%% Read cell info.
[num,txt,raw] = xlsread(fullfile(Inputs.cellInfoFile));
fields = raw(1,:);
cellInfo = cell2struct(raw(2:end,:),fields,2);

%% Read HeatMaps.
nNeurons = size({cellInfo.ID},2);
neurons = {cellInfo.ID};
pixValues = [];
hxyz = [];
for iNeuron = 1:nNeurons
   % load file.
   cNeuron = neurons{iNeuron}; 
   cHeatMapFile = fullfile(Inputs.resultFolder,Inputs.anaMask,sprintf('%s_%s.mat',cNeuron,Inputs.anaMask));
   heatmap = load(cHeatMapFile);
   % order values.
   pixValues = [pixValues;heatmap.heatIm(heatmap.ontIm)'];
   % hxyz.
   ind = find(heatmap.ontIm);
   [x,y,z] = ind2sub(size(heatmap.ontIm),ind);
   hxyz = cat(3,hxyz,double([heatmap.heatIm(heatmap.ontIm),x,y,z]));
end
% select onyl positive voxels
pixValues = pixValues(:,any(pixValues>0,1));
hxyz = hxyz(any(hxyz(:,1,:)>0,3),:,:);
% %% Pca.
% % pixValues = pixValues(:,any(pixValues,1));
% coeff = pca(double(pixValues)');
% hFig = figure('Color',[0,0,0]);
% hAx = axes();
% hAx.Color = [0,0,0];
% hAx.XColor = [1,1,1];
% hAx.YColor = [1,1,1];
% hAx.TickDir = 'out';
% hold on
% % Legend.
% hL = legend;
% hL.Color = [1,1,1];
% hL.Location = 'bestoutside';
% for iNeuron = 1:nNeurons
%     hS = scatter3(coeff(iNeuron,1),coeff(iNeuron,2),coeff(iNeuron,3),50,'filled');
%     hT = text(coeff(iNeuron,1),coeff(iNeuron,2)+0.01,coeff(iNeuron,3),neurons{iNeuron});
%     hT.Color = hS.CData; hT.HorizontalAlignment = 'center';
%     hT.VerticalAlignment = 'bottom';
% end
% hL.String = neurons;
% % 
% % % cross correlation.
% % convn(x3d,y3d(end:-1:1,end:-1:1,end:-1:1))


% 
%% Calculate distances.
% pair distance based on mindistace-match-heatmap
dminmax = distfun_weighted(hxyz);
dm = max(dminmax(:,:,1),dminmax(:,:,2));
distMat = squareform(max(dm,dm'));

% % custom distance measure. (area based on pairwise area).
% fh = str2func(Inputs.DistanceFunction);
% distMat = pdist(pixValues,'spearman');
% 
% %% Erhans method (area based on all cells.)
% distMat = pdist(pixValues>0,'jaccard');

%% Linkage
Z = linkage(distMat,Inputs.LinkageMethod);
c = cluster(Z,'cutoff',Inputs.Cutoff);
leafOrder = optimalleaforder(Z,distMat);

%% Dendrogram.
dendrogram(Z,'Orientation','right','Labels',neurons,'Reorder',fliplr(leafOrder))

%% MDS
[Y,stress] =... 
mdscale(distMat,2,'criterion',Inputs.MdsCriterion);
% [Y,e] = cmdscale(distMat);
hFig = figure('Color',[0,0,0]);
hAx = axes();
hAx.Color = [0,0,0];
hAx.XColor = [1,1,1];
hAx.YColor = [1,1,1];
hAx.TickDir = 'out';
hold on
% Legend.
hL = legend;
hL.Color = [1,1,1];
hL.Location = 'bestoutside';
for iNeuron = 1:nNeurons
    hS = scatter(Y(iNeuron,1),Y(iNeuron,2),50,'filled');
    hT = text(Y(iNeuron,1),Y(iNeuron,2)+0.01,neurons{iNeuron});
    hT.Color = hS.CData; hT.HorizontalAlignment = 'center';
    hT.VerticalAlignment = 'bottom';
end
hL.String = neurons;

end

