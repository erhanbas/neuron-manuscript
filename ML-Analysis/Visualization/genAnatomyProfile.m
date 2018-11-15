function [ hFig, result ] = genAnatomyProfile( neuronIDs, anatomyNames, varargin )
%genAnatomyProfile. Creates plots showing the binned axonal density of a certain structure
% for different projection directions.
%% Parse input.
p = inputParser;
p.addRequired('neuronIDs',@(x) iscell(x) || ischar(x));
p.addRequired('anatomyNames',@(x) iscell(x) || ischar(x));
p.addParameter('BinSize',[100,100,100],@(x) isequal(size(x),[1,3]));
p.addParameter('Title','',@(x) ischar(x));
p.addParameter('YLims',[],@(x) isnumeric(x) && isequal(size(x),[3,2]));
p.addParameter('ErrorProperties',{},@(x) iscell(x) && isequal(size(x),[1,2]));
p.addParameter('MeshFile',fullfile('//nrs/mouselight/Shared Files/Mesh Info/allenMesh.mat'),@(x) ischar(x));
p.parse(neuronIDs, anatomyNames, varargin{:});
Inputs = p.Results;
% cast variables.
halfPoint = 5695;
if ischar(Inputs.neuronIDs), Inputs.neuronIDs = {Inputs.neuronIDs}; end
if ischar(Inputs.anatomyNames), Inputs.anatomyNames = {Inputs.anatomyNames}; end

%% Load mesh
fprintf('\nLoading mesh file..');
load(Inputs.MeshFile);

%% Generate voxelized brain area.
[ ontIm ] = VoxelizedBrainArea( Inputs.BinSize, Inputs.anatomyNames, allenMesh);

%% Fill in neuron density info per neuron (4th Dim is neuron#)
nNeurons = size(Inputs.neuronIDs,2);
fullResIm = zeros([size(ontIm),nNeurons],'uint16');
for iNeuron = 1:nNeurons
    cNeuron = Inputs.neuronIDs{iNeuron};
    fprintf('\nProcessing Neuron %s [%i\\%i]',cNeuron,iNeuron,nNeurons);
    % get neuron.
    neuron = getNeuronfromIdString(Inputs.neuronIDs{iNeuron},'ForceHemi','right');
    % Downsample.
    swcData = [[neuron.axon.sampleNumber]',[neuron.axon.structureIdValue]',...
        [neuron.axon.x]',[neuron.axon.y]',[neuron.axon.z]',...
        ones(size([neuron.axon.y]',1),1), [neuron.axon.parentNumber]'];
    [coords] = upsampleSWC(swcData,1);
    % Select nodes in anatomy region.
    pixPos = ceil(coords./repmat(Inputs.BinSize,size(coords,1),1));
    pixPos = sub2ind(size(ontIm),pixPos(:,1),pixPos(:,2),pixPos(:,3));
    pixPos(isnan(pixPos)) = 1;
    coords = coords(ontIm(pixPos),:);
    % go through nodes.
    for iNode = 1:size(coords,1)
        xPos = ceil(coords(iNode,1)/Inputs.BinSize(1));
        yPos = ceil(coords(iNode,2)/Inputs.BinSize(2));
        zPos = ceil(coords(iNode,3)/Inputs.BinSize(3));
        fullResIm(xPos,yPos,zPos,iNeuron) = fullResIm(xPos,yPos,zPos,iNeuron)+1;
    end
end

%% Bin projections.
hFig = figure('Color',[0,0,0]);
set(hFig, 'Position', get(0, 'Screensize'));
% 1: ipsi, 2: contra
subPlotIds = [1,3,5;2,4,6];
dimNames = {'x','y','z'};
hemiNames = {'ipsi','contra'};
result = [];
result.Inputs = Inputs;
for iHemi = 1:2
    resIm = fullResIm;
    hemiOntIm =ontIm;
    halfPointInd = ceil(size(fullResIm,1)/2);
    if iHemi == 1
        resIm(halfPointInd+1:end,:,:,:) = 0;
        hemiOntIm(halfPointInd+1:end,:,:,:) = 0;
    else
        resIm(1:halfPointInd,:,:,:) = 0;
        hemiOntIm(1:halfPointInd,:,:,:) = 0;
    end
    for iDim = 1:3
        hAx = subplot(3,2,subPlotIds(iHemi,iDim));
        % Sum along dimensions (collumns is different neurons).
        dimOrder = [1,2,3];
        dimOrder = circshift(dimOrder,-(iDim-1));
        dimVal = permute(resIm,[dimOrder,4]);
        dimVal = squeeze(sum(sum(dimVal,2),3));
        % find min/max of projection dimension.
        ontVal = permute(hemiOntIm,dimOrder);
        ontVal = squeeze(sum(sum(ontVal,2),3));
        rangeOnt = [min(find(ontVal)),max(find(ontVal))];
        % crop values.
        dimVal = dimVal(rangeOnt(1):rangeOnt(2),:);
        % Get average, std  and sem
        posVal = [rangeOnt(1)*Inputs.BinSize(iDim):Inputs.BinSize(iDim):rangeOnt(2)*Inputs.BinSize(iDim)]';
        avgVal = mean(dimVal,2);
        stdVal = std(dimVal,[],2);
        semVal =  stdVal/sqrt(nNeurons);
        % Store.
        result.(hemiNames{iHemi}).(dimNames{iDim})= struct('pos',posVal,'avg',avgVal,'std',stdVal,'sem',semVal);
        % Plot.
        axesNames ={'Left-right axis','Dorsoventral axis','Anteroposterior axis'};
        hError = errorbar(posVal,avgVal,semVal);
        if ~isempty(Inputs.ErrorProperties)
            set(hError,Inputs.ErrorProperties{1},Inputs.ErrorProperties{2});
        end
        hAx.TickDir = 'out';
        hAx.XColor = [1,1,1]; hAx.YColor = [1,1,1]; hAx.ZColor = [1,1,1]; 
        hAx.Color = [0,0,0];
        box off
        xlabel(sprintf('%s (\\mum)',axesNames{iDim}));
        ylabel('Axon Length (\mum)');
        if ~isempty(Inputs.YLims), ylim(Inputs.YLims(iDim,:)); end
        if iHemi==1 && iDim==1
            title('\color{white}Ipsilateral');
        elseif iHemi==2 && iDim==1
            title('\color{white}Contralateral');
        end
    end
end
if ~isempty(Inputs.Title), h = suptitle(sprintf('%s',Inputs.Title)); end
h.Color = [1,1,1];
end

