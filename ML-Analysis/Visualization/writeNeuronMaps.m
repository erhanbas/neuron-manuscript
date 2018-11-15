function writeNeuronMaps(outputFile, neurons, colors, varargin)
%% Parse input.
p = inputParser;
p.addRequired('outputFile',@(x) ischar(x) && strcmpi(x(end-3:end),'.tif'));
p.addRequired('neurons',@(x) iscell(x));
p.addRequired('colors',@(x) isnumeric(x));
p.addParameter('Projection','coronal',@(x) any(strcmpi(x,{'coronal','sagittal','horizontal'})));
p.addParameter('Type','axon',@(x) strcmpi(x,'axon') || strcmpi(x,'dendrite'));
p.addParameter('ScaleFactor',0.2,@(x) x>=0 && x<=1);
p.addParameter('OpacityFactor',0.8,@(x) x>=0 && x<=1);
p.addParameter('OntAtlas',fullfile('\\dm11\mousebrainmicro\registration\Database\OntAtlasMesh8bit.nrrd'),@(x) ischar(x));
p.addParameter('SignalDilation',[1,1,5],@(x) all(size(x) == [1,3]));
p.parse(outputFile, neurons, colors, varargin{:});
Inputs = p.Results;

%% load ontlogy atlas.
fprintf('\nLoading background image');
[IBg,meta] = nrrdread(Inputs.OntAtlas);
tMat = nrrdMeta2TMat(meta);
IBg = imresize3(IBg,Inputs.ScaleFactor);
tMat = tMat*Inputs.ScaleFactor;
%% Adjust scale factor according to projection.
switch lower(Inputs.Projection)
    case 'horizontal'
        Inputs.SignalDilation = Inputs.SignalDilation([3,2,1]);
    case 'sagittal'
        Inputs.SignalDilation = Inputs.SignalDilation([1,3,2]);
end

%% Create res Image.
nNeurons = length([Inputs.neurons{:}]);
IBg = cat(4,IBg,IBg,IBg);
IRes = NaN(size(IBg,1),size(IBg,2),size(IBg,3),size(IBg,4),nNeurons);

%% Plot axons.
neurons = Inputs.neurons;
for iNeuron = 1:size(neurons,2)
    fprintf('\n%s [%i\\%i]',neurons{iNeuron},iNeuron,size(neurons,2));
    neuron = getNeuronfromIdString(neurons{iNeuron},'ForceHemi','right');
    nodes = [[neuron.(Inputs.Type).x]',[neuron.(Inputs.Type).y]',[neuron.(Inputs.Type).z]'];
    pixPos = unique(round(nodes*tMat(1:3,1:3)),'rows');
    pixPos = pixPos(:,[2,1,3]);
    %% Add expansion signal in Z.
    temp = zeros(size(IRes,1),size(IRes,2),size(IRes,3),'logical');
    ind = sub2ind(size(temp),pixPos(:,1),pixPos(:,2),pixPos(:,3));
    temp(ind) = true;
    temp = imdilate(temp,strel('cuboid',Inputs.SignalDilation));
    [i,j,k] = ind2sub(size(temp),find(temp));
    pixPos = [i,j,k];
    for iPix = 1:size(pixPos,1)
        IRes(pixPos(iPix,1),pixPos(iPix,2),pixPos(iPix,3),:,iNeuron) = uint8(colors(iNeuron,:)*255);
    end
end

%% Take average color value at pixels.
IRes = nanmean(IRes,5);
IRes = uint8(IRes);
bgMask = IRes==0;% If no signal then color is bgcolor
IRes = (IBg*(1-Inputs.OpacityFactor)) + (IRes*Inputs.OpacityFactor);
IRes(bgMask) = IBg(bgMask);

%% Save results.
fprintf('\nSaving Result %s',Inputs.outputFile);
options.color = true; 
options.compress = 'no'; 
options.message = false; 
options.append = false; 
options.overwrite = true; 
options.big = false;
switch lower(Inputs.Projection)
    case 'coronal'
        IRes = permute(IRes,[1,2,4,3]);
    case 'horizontal'
        IRes = permute(IRes,[3,2,4,1]);
    case 'sagittal'
        IRes = permute(IRes,[1,3,4,2]);
end
saveastiff(IRes,Inputs.outputFile,options);
fprintf('\n');        
