function [ result ] = genClusterFileManual( clusterFile, cellInfoFile, outputFolder, varargin)
%runClusterHeatMap. Run clustering algorithm for supplied anatomy masks
%% Parse input.
p = inputParser;
p.addRequired('clusterFile',@(x) ischar(x) || iscell(x) && size(x,1)==1);
p.addRequired('cellInfoFile',@(x) ischar(x) && strcmpi(x(end-4:end),'.xlsx'));
p.addRequired('outputFolder',@(x) ischar(x));
p.parse(clusterFile, cellInfoFile,outputFolder, varargin{:});
Inputs = p.Results;
if ~isdir(Inputs.outputFolder), mkdir(Inputs.outputFolder); end
%% get cells.
[cellGroup,cells,~] = xlsread(Inputs.clusterFile);
if size(cells,2)>1 || size(cellGroup,2)>1 || size(cells,1)~=size(cellGroup,1)
    error('Incorrectly formated manual cluster file');
end
cells =cells';
[~,mask,~] =fileparts(Inputs.clusterFile);
%% generate color.
groupColor = hsv(max(cellGroup));

%% Read cell info.
[num,txt,raw] = xlsread(fullfile(Inputs.cellInfoFile));
fields = raw(1,:);
cellInfo = cell2struct(raw(2:end,:),fields,2);
% selected only selected file.
ids = {cellInfo.ID};
[~,ind] = cellfun(@(x) ismember(x,ids),cells,'UniformOutput',false);
ind = [ind{:}]';
cellInfo = cellInfo(ind);


%% Order by group. 
[~,ind] =sort(cellGroup);

%% Store.
result = [];
result.mask = mask;
result.cells = cells(ind);
result.cellInfo = cellInfo(ind);
result.cellGroup = cellGroup(ind);
result.groupColor = groupColor;




%% Make figure (just for reference).
hFig = figure('units','normalized','outerposition',[0 0 .5 1],'Color',[0,0,0]);
hAx = axes('Color',[0,0,0],...
    'TickDir','out',...
    'YDir','reverse');
for iCell =1:size(result.cells,2)
   text(10,iCell*10,sprintf('%s, %s - %i',result.cells{iCell},...
       result.cellInfo(iCell).Area, round(result.cellInfo(iCell).Depth)),...
       'Color',result.groupColor(result.cellGroup(iCell),:));
end
xlim([5,20]);
ylim([0,size(result.cells,2)*10+20]);
%% save.
save(fullfile(Inputs.outputFolder,sprintf('Clustering Result %s',mask)),'result');
export_fig(gcf,fullfile(Inputs.outputFolder,sprintf('Clustering Result %s.png',mask)),'-a4','-m2','-nocrop');

end