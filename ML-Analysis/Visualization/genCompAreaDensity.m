function [ hFig, data ] = genCompAreaDensity( mainFolder, neuronGroups, anaMask, varargin )
%genCompAreaDensity. Makes bor plot and output statistics for comparing
%the occupied volume and density for groups of neurons in aspecific anatomical region (anaMask) 
%% Parse input.
p = inputParser;
p.addRequired('mainFolder',@(x) ischar(x));
p.addRequired('neuronGroups',@(x) iscell(x));
p.addRequired('anaMask',@(x) ischar(x));
p.addParameter('VoxelSize',[150,150,150],@(x) isnumeric(x) & isequal(size(x),[1,3]));
p.addParameter('Color',[],@(x) isnumeric(x) & size(x,2)==3);
p.addParameter('Labels',{},@(x) iscell(x));
p.parse(mainFolder, neuronGroups, anaMask, varargin{:});
Inputs = p.Results;

nGroups = size(Inputs.neuronGroups,1);
if isempty(Inputs.Labels)
    for i=1:nGroups
        Inputs.Labels = [Inputs.Labels;sprintf('Group %i',i)];
    end
end
%% Collect Data.

data=[];
for iGroup = 1:nGroups
    cGroup = Inputs.neuronGroups{iGroup};
    nNeurons = size(cGroup,2);
    areaVal = [];
    densityVal = [];
    for iNeuron=1:nNeurons
        cNeuron = cGroup{iNeuron};
        % load heatmap.
        heatMapFile = fullfile(Inputs.mainFolder,anaMask,sprintf('%s_%s.mat',cNeuron,Inputs.anaMask));
        load(heatMapFile);
        % Get Volume.
        voxelVolume = (Inputs.VoxelSize(1)*Inputs.VoxelSize(2)*Inputs.VoxelSize(3))*10^-9; % mm3
        cArea = sum(sum(sum(heatIm>0)))*voxelVolume;
        % Get Density
        cDensity = (sum(heatIm(heatIm>0))/1000)/cArea; %mm/mm3
        % Store.
        areaVal = [areaVal;sum(sum(sum(heatIm>0)))*voxelVolume];
        densityVal = [densityVal; cDensity];
    end
    cData = [];
    cData.areaVal = areaVal;
    cData.densityVal = densityVal;
    cData.avgArea = mean(cData.areaVal);
    cData.avgDensity = mean(cData.densityVal);
    cData.stdArea = std(cData.areaVal,[]);
    cData.stdDensity = std(cData.densityVal,[]);
    cData.semArea = cData.stdArea/sqrt(nNeurons);
    cData.semDensity = cData.stdDensity/sqrt(nNeurons);
    data = [data;cData];
end

%% Plot Volume.
hFigArea = figure('Color',[0,0,0]);
hAx = axes('Color',[0,0,0]); hold on;
hAx.XColor =[1,1,1]; hAx.YColor = [1,1,1]; 
hAx.TickDir= 'out'; hAx.Box = 'off';
% bar.
c = categorical(Inputs.Labels);
hBar = bar(c,[data.avgArea]);
% set color.
hBar.FaceColor = 'flat';
for iGroup = 1:nGroups
   hBar.CData(iGroup,:) = Inputs.Color(iGroup,:); 
end
hError = errorbar([1:nGroups],[data.avgArea],zeros(nGroups,1),[data.semArea]);
hError.LineStyle = 'none'; hError.LineWidth = 1.5; hError.Color =[1,1,1]; hError.CapSize=12;
hTitle = title(sprintf('Mask: %s',strrep(anaMask,'_','-')));
hTitle.Color = hAx.XColor;
ylabel('Volume (mm^3)');
% Output stats.
fprintf('\nVolume information: %s',Inputs.anaMask)
for iGroup=1:nGroups
    fprintf('\n%s: %.3f +- %.3f	mm3 (n: %i)',Inputs.Labels{iGroup},data(iGroup).avgArea,data(iGroup).stdArea,length(data(iGroup).areaVal));
end
% Test Stats.
groupComb = combnk([1:nGroups],2);
for iComb = 1:size(groupComb,1)
    [~,p] = ttest2(data(groupComb(iComb,1)).areaVal,data(groupComb(iComb,2)).areaVal);
    fprintf('\nArea %s vs %s p: %.4f',Inputs.Labels{groupComb(iComb,1)},...
    Inputs.Labels{groupComb(iComb,2)}, p);
end
fprintf('\n');

%% Plot Density.
hFigDens = figure('Color',[0,0,0]);
hAx = axes('Color',[0,0,0]); hold on;
hAx.XColor =[1,1,1]; hAx.YColor = [1,1,1]; 
hAx.TickDir= 'out'; hAx.Box = 'off';
% bar.
c = categorical(Inputs.Labels);
hBar = bar(c,[data.avgDensity]);
% set color.
hBar.FaceColor = 'flat';
for iGroup = 1:nGroups
   hBar.CData(iGroup,:) = Inputs.Color(iGroup,:); 
end
hError = errorbar([1:nGroups],[data.avgDensity],zeros(nGroups,1),[data.semDensity]);
hError.LineStyle = 'none'; hError.LineWidth = 1.5; hError.Color =[1,1,1]; hError.CapSize=12;
hTitle = title(sprintf('Mask: %s',strrep(anaMask,'_','-')));
hTitle.Color = hAx.XColor;
ylabel('Density (mm/mm^3)');
% Output stats.
fprintf('\nDensity information: %s',Inputs.anaMask)
for iGroup=1:nGroups
    fprintf('\n%s: %.3f +- %.3f	mm3 (n: %i)',Inputs.Labels{iGroup},data(iGroup).avgDensity,...
        data(iGroup).stdDensity,length(data(iGroup).densityVal));
end
% Test Stats.
groupComb = combnk([1:nGroups],2);
for iComb = 1:size(groupComb,1)
    [~,p] = ttest2(data(groupComb(iComb,1)).densityVal,data(groupComb(iComb,2)).densityVal);
    fprintf('\nArea %s vs %s p: %.4f',Inputs.Labels{groupComb(iComb,1)},...
    Inputs.Labels{groupComb(iComb,2)}, p);
end
fprintf('\n');
hFig = [hFigArea,hFigDens];
end

