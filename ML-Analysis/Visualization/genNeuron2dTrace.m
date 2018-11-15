function [handles] = genNeuron2dTrace(neuronStr,projection, varargin)
%genNeuronTrace. Generates 2d projection of neuron reconstruction.
% can also add allen region outline.
% defaultFormatting = [];
% defaultFormatting.dendrite = struct('LineWidth',2,'
%% Parse input.
p = inputParser;
p.addRequired('neuronStr',@(x) iscell(x) || ischar(x));
p.addRequired('projection',@(x) ischar(x));
p.addParameter('Regions',{'whole brain'},@(x) iscell(x) || ischar(x));
p.addParameter('RegionColor',[],@(x) isnumeric(x) & size(x,2)==3); % region color is matrix of size nRegionsx3
p.addParameter('Color',[],@(x)isnumeric(x) || iscell(x)); % (color is cell 1xnNeurons where each cell is matrix of rgb values for axon and dendrite (2x3))
p.addParameter('LineWidth',[1,2,3],@(x) isnumeric(x) & isequal(size(x),[1,3])); %size 1x2, first:axon second:dendrite third: regions,
p.addParameter('XLim',[],@(x) isnumeric(x) & isequal(size(x),[1,2]));
p.addParameter('YLim',[],@(x) isnumeric(x) & isequal(size(x),[1,2]));
p.addParameter('SliceRange',[],@(x) isnumeric(x) & isequal(size(x),[1,2]));
p.addParameter('AllenSlice',false,@(x) islogical(x));
p.addParameter('AllenFile','\\dm11\mousebrainmicro\registration\Allen Atlas\AllenAtlas8bit.nrrd',@(x) ischar(x));
p.parse(neuronStr,projection, varargin{:});
Inputs = p.Results;

% conversions.
if ischar(Inputs.neuronStr), Inputs.neuronStr={Inputs.neuronStr}; end
if ischar(Inputs.Regions), Inputs.Regions={Inputs.Regions}; end
if isnumeric(Inputs.Color), Inputs.Color = {Inputs.Color}; end
if ~isempty(Inputs.Color) && size(Inputs.Color,2)~=size(Inputs.neuronStr,2)
    error('Number of colors does not match number of neurons (color is cell 1xN where is cell is rgb value for axon and dendrite 2x3)');
end
if ~isempty(Inputs.RegionColor) && size(Inputs.RegionColor,1)~= size(Inputs.Regions,2) 
    error('Number of colors does not match number of Regions');
end
if ~ismember(Inputs.projection,{'coronal','saggital','transverse','horizontal'})
    error('Projection %s not recognized',Inputs.projection);
end
if isempty(dir(Inputs.AllenFile)) && Inputs.AllenSlice
    error('Could not find file %s\nMaybe on different drive letter',Inputs.AllenFile);
end
% check color formatting.
sizeColors = cellfun(@(x) size(x,1)==2,Inputs.Color);
if any(sizeColors==false)
    error('Colors should be provided as cell of 1xnNeurons where each cell is 2x3');
end
sizeColors = cellfun(@(x) size(x,2)==3,Inputs.Color);
if any(sizeColors==false)
    error('Colors should be provided as cell of 1xnNeurons where each cell is 2x3');
end
%% Setup projections.
axisNames = {'Left-right axis','Dorsoventral axis','Anteroposterior axis'};
switch Inputs.projection
    case 'saggital'
        dimSelection = [3,2];
        if isempty(Inputs.XLim), Inputs.XLim = [-1000,14000]; end
        if isempty(Inputs.YLim), Inputs.YLim = [0,9000]; end
        if isempty(Inputs.SliceRange), Inputs.SliceRange= [0, 11400]; end
    case 'coronal'
        dimSelection = [1,2];
        if isempty(Inputs.XLim), Inputs.XLim = [0,11400]; end
        if isempty(Inputs.YLim), Inputs.YLim = [0,8000]; end
        if isempty(Inputs.SliceRange), Inputs.SliceRange= [0, 13200]; end
    case {'transverse','horizontal'}
        dimSelection = [3,1];
        if isempty(Inputs.XLim), Inputs.XLim = [-1000,14000]; end
        if isempty(Inputs.YLim), Inputs.YLim = [0,11400]; end
        if isempty(Inputs.SliceRange), Inputs.SliceRange= [0, 8000]; end
end
sliceDim = find(~ismember([1,2,3],dimSelection));

%% Setup figure.
handles.hFig = figure('Color',[1,1,1]);
handles.hAx = axes();
handles.hAx.TickDir = 'out';
handles.hAx.YDir = 'reverse';
handles.hAx.FontName = 'Arial';
handles.hAx.XLim = Inputs.XLim;
handles.hAx.YLim = Inputs.YLim;
handles.hAx.DataAspectRatio = [1,1,1];
xlabel(axisNames{dimSelection(1)});
ylabel(axisNames{dimSelection(2)});
hold on

%% Plot outlines.
count = 1;
for iReg = 1:size(Inputs.Regions,2)
   cReg = Inputs.Regions(iReg);
   [ x,y,color] = getRegionMaskOutline( cReg, dimSelection, Inputs.SliceRange );
   if strcmpi(cReg,'whole brain'), color = [0,0,0]; end
   if ~isempty(Inputs.RegionColor), color = Inputs.RegionColor(iReg,:); end
   for i =1:size(x,1)
       handles.hOutline(count) = plot(x{i}(1:10:end),y{i}(1:10:end),'Color',color,'LineStyle','--','LineWidth',Inputs.LineWidth(3));
       count = count+1;
   end
end

%% Show neurons.
for iNeuron = 1:size(Inputs.neuronStr,2)
    % load neuron
    cNeuron = Inputs.neuronStr{iNeuron};
    neuron = getNeuronfromIdString(cNeuron);
    % Go through axon and dendrite.
    types = {'axon','dendrite'};
    for iType = 1:2 % 1 is axon 2 is dendrite.
        cType = types{iType};
        if ~isempty(neuron.(cType))
            handles.(cType)(iNeuron) = plotNeuronFast2D( neuron.(cType),dimSelection);
            handles.(cType)(iNeuron).LineWidth = Inputs.LineWidth(iType);
            if ~isempty(Inputs.Color)
                handles.(cType)(iNeuron).Color = Inputs.Color{iNeuron}(iType,:);
            end
        end
    end
end

%% Show allen slice if requested (off by default)
if Inputs.AllenSlice
    % Load allen Info.
    IAllen = nrrdread(Inputs.AllenFile);
    IAllen = permute(IAllen,[2,1,3]); 
    % display.
    Ibg = permute(IAllen,[dimSelection(2),dimSelection(1),sliceDim]);
    sliceRangePix = round(Inputs.SliceRange/10);
    if sliceRangePix(1)==0, sliceRangePix(1)=1; end
    Ibg = mean(Ibg(:,:,sliceRangePix(1):sliceRangePix(2)),3);
    R = imref2d(size(Ibg),10,10);
    handles.hIm = imshow(imcomplement(Ibg),R,[]);
    uistack(handles.hIm,'bottom') ;
end

end

