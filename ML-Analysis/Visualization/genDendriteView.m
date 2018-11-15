function [ hFigStore ] = genDendriteView( neuronIDs, depth, varargin )
%genDendriteView. Generates figure showing dendritic reconstructions of 
% provided neurons Ids
%% Parse input.
p = inputParser;
p.addRequired('neuronIDs',@(x) iscell(x) || ischar(x) && size(x,1)==1);
p.addRequired('depth',@(x) isnumeric(x) && size(x,1)==1);
p.addParameter('MaxN',10,@(x) isnumeric(x) && length(x)==1);
p.addParameter('OffsetX',350,@(x) isnumeric(x) && length(x)==1);
p.addParameter('RotationAngles',[0,0,0],@(x) isnumeric(x) & size(x,2)==3);
p.addParameter('YLim',[],@(x) isnumeric(x) && isequal(size(x),[1,2]));
p.addParameter('LineProperties',{},@(x) iscell(x) && isequal(size(x),[1,2]));
p.addParameter('FlatMapFolder','//nrs/mouselight/Shared Files/flatMap',@(x) ischar(x));
% parse.
p.parse(neuronIDs, depth, varargin{:});
Inputs = p.Results;
if ischar(Inputs.neuronIDs), Inputs.neuronIDs = {Inputs.neuronIDs}; end
% check depth and cell number match
if size(Inputs.neuronIDs,2) ~= size(Inputs.depth,2)
    error('Number of provided cells does not match depth information');
end
if size(Inputs.neuronIDs,2) ~= size(Inputs.RotationAngles,1)
    error('Number of provided cells does not match Rotation Angles info');
end

%% Go through neurons
hFigStore = [];
nNeurons = size(Inputs.neuronIDs,2);
for iNeuron = 1:nNeurons
    cNeuron = Inputs.neuronIDs{iNeuron};
    fprintf('\nNeuron: %s [%i\\%i]',cNeuron,iNeuron,nNeurons);
    % create figure.
    if mod(iNeuron,Inputs.MaxN)==1
        hFig = figure('Color',[0,0,0]);
        set(hFig, 'Position', get(0, 'Screensize'));
        hAx = axes;
        hAx.TickDir = 'out';
        hAx.XColor = [1,1,1]; hAx.YColor = [1,1,1]; hAx.ZColor = [1,1,1]; 
        box off
        hAx.Color = [0,0,0]; hold on
        hAx.DataAspectRatio = [1,1,1];
        if ~isempty(Inputs.YLim), ylim(Inputs.YLim); end
        xlabel('(\mum)'); ylabel('Depth (\mum)');
        hFigStore = [hFigStore;hFig];
    end
    % Load Neuron.
    neuron = getNeuronfromIdString(cNeuron,'ForceHemi','right','Type','dendrite');
    % Center neuron around soma.
    swc = [[neuron.dendrite.sampleNumber]' [neuron.dendrite.structureIdValue]' [neuron.dendrite.x]' -[neuron.dendrite.y]'...
        [neuron.dendrite.z]' ones(size(neuron.dendrite,1),1) [neuron.dendrite.parentNumber]'];
    for iDim = 3:5
       swc(:,iDim) = swc(:,iDim) - swc(1,iDim);
    end
    % Rotate around origin (soma)
    swc(:,3:5) = rotateCoordinates(swc(:,3:5),...
        Inputs.RotationAngles(iNeuron,1),Inputs.RotationAngles(iNeuron,2),Inputs.RotationAngles(iNeuron,3));
    % add depth
    swc(:,4) = swc(:,4)-Inputs.depth(iNeuron);
    % add ofset x.
    offset = (mod(iNeuron,Inputs.MaxN)-1)*Inputs.OffsetX;
    swc(:,3) = swc(:,3) + offset;
    % Plot Dendrite.
    hNeuron = plotSwcFast2D(swc,[1,2]);
    hNeuron.LineWidth = 1.5;
    if ~isempty(Inputs.LineProperties)
        set(hNeuron,Inputs.LineProperties{1},Inputs.LineProperties{2});
    end
    % Plot Soma.
    hSoma = scatter( swc(1,3),swc(1,4),250,'filled');
    hSoma.MarkerFaceColor = hNeuron.Color;
    hSoma.MarkerEdgeColor = [1,1,1];
    hSoma.LineWidth = 1.5;

    % Cell Name.
    hText = text(offset, hAx.YLim(2)-50, cNeuron,'HorizontalAlignment','center','Color','white',...
        'FontSize',14);
end

end

