function [] = fullAnatomyXls(neuronIDs,outputFile,varargin)
%fullAnatomyXls. Generates xls with axonal information per anatomical
%region. Used to select regions for later anatomy tables.
%% Parse input.
p = inputParser;
p.addRequired('neuronIDs',@(x) ischar(x) | iscell(x));
p.addRequired('outputFile',@(x) ischar(x));
% parse.
p.parse(neuronIDs, outputFile, varargin{:});
Inputs = p.Results;

if ischar(Inputs.neuronIDs), Inputs.neuronIDs={Inputs.neuronIDs}; end

%% load neuron info.
nNeurons = size(Inputs.neuronIDs,2);
neuron = [];
for iNeuron=1:nNeurons
    % Load neuron.
    cNeuron = Inputs.neuronIDs{iNeuron};
    fprintf('\nLoading %s [%i\\%i]',cNeuron,iNeuron,nNeurons);
    neuron = [neuron;getNeuronfromIdString(cNeuron,'Type','axon')];
end

%% Get unique anatomical regions.
idList = [];
uniAnatomy = [];
for iNeuron =1:nNeurons
    structIds = {neuron(iNeuron).axon.structureId};
    tempNeuron = neuron(iNeuron).axon(cellfun(@(x) ~isempty(x),structIds));
    [C,ia,~] = unique([tempNeuron.structureId]);
    ia = ia(~ismember(C,idList) & ~isempty(C));
    temp = tempNeuron(ia);
    temp = rmfield(temp,{'sampleNumber','x','y','z','parentNumber','structureIdValue'});
    uniAnatomy = [uniAnatomy;temp];
    idList = [idList;C'];
end

%% Sort.
[~,I] = sort({uniAnatomy.structureIdPath});
uniAnatomy = uniAnatomy(I);
nRegions = size(uniAnatomy,1);

%% Collect info per region.
fprintf('\nProcessing %i unique regions..',nRegions);
countMsg = sprintf('[%i\\%i]',0,nRegions);
fprintf('\n%s',countMsg);
for iRegion = 1:nRegions
    for i=1:length(countMsg), fprintf('\b'); end
    countMsg = sprintf('[%i\\%i]',iRegion,nRegions);
    fprintf('%s',countMsg);
    cStructIdPath = uniAnatomy(iRegion).structureIdPath;
    totalLength = 0;
    nBranches = 0;
    nEndPoints = 0;
    for iNeuron = 1:nNeurons
        info = neuronInfoAllenRegion(neuron(iNeuron),cStructIdPath);
        totalLength = totalLength + info.bi.totalLength;
        nBranches = nBranches + info.bi.nBranches;
        nEndPoints = nEndPoints + info.bi.nEndPoints;
    end
    uniAnatomy(iRegion).length = totalLength/1000;%mm
    uniAnatomy(iRegion).nBranches = nBranches;
    uniAnatomy(iRegion).nEndPoints = nEndPoints;
end

%% Write xls.
fprintf('\nWriting %s',Inputs.outputFile);
struc2xls(Inputs.outputFile,uniAnatomy);
fprintf('\nDone!\n');
end

