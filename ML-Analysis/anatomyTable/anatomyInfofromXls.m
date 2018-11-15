function [data] = anatomyInfofromXls(neuronIDs,anatomyXls,varargin)
%anatomyInfofromXls. Gathers anatomy info from given neuron list and custom
%anatomy location listed in xls file.
%% Parse input.
p = inputParser;
p.addRequired('neuronIDs',@(x) (ischar(x) | iscell(x)) & size(x,1)==1);
p.addRequired('anatomyXls',@(x) ischar(x));
p.addParameter('outputFile','',@(x) ischar(x) & strcmp(x(end-3:end),'.mat'));
% parse.
p.parse(neuronIDs,anatomyXls, varargin{:});
Inputs = p.Results;
if ischar(Inputs.neuronIDs), Inputs.neuronIDs={Inputs.neuronIDs}; end

%% Gather requested anatomy info.
anatomy = xls2struct(Inputs.anatomyXls);
if ~isfield(anatomy,'structureIdPath'), error('No Collumn labelled as structureIdPath'); end
structIdPaths = [anatomy.structureIdPath];
nRegions = size(structIdPaths,1);

%% get Anatomy info from database.
anatomyInfo =[];
for iRegion = 1:nRegions
    structId = textscan(structIdPaths{iRegion},'%d','Delimiter','/');
    structId = [structId{:}];
    anatomyInfo =[anatomyInfo;getAllenAreaInfo(structId(end))];
end

%% Collect anatomy info.
nNeurons = size(Inputs.neuronIDs,2);
data = [];
data.Cells = Inputs.neuronIDs;
data.bi.nBranches = zeros(nNeurons,nRegions);
data.bi.nEndPoints = zeros(nNeurons,nRegions);
data.bi.length = zeros(nNeurons,nRegions);
data.ipsi = data.bi;
data.contra = data.bi;
data.laterality = cell(nNeurons,nRegions);
data.anatomy = anatomyInfo;
fields = {'bi','ipsi','contra'};
for iNeuron=1:nNeurons
    cNeuron = Inputs.neuronIDs{iNeuron};
    fprintf('\nProcessing %s [%i\\%i]',cNeuron,iNeuron,nNeurons);
    neuron = getNeuronfromIdString(cNeuron,'Type','axon');
    for iRegion = 1:nRegions
       cPath = anatomyInfo(iRegion).structureIdPath ;
       info = neuronInfoAllenRegion(neuron,cPath);
       for iField = fields
          cField = iField{:};
          data.(cField).nBranches(iNeuron,iRegion) = info.(cField).nBranches;
          data.(cField).nEndPoints(iNeuron,iRegion) = info.(cField).nEndPoints;
          data.(cField).length(iNeuron,iRegion) = info.(cField).totalLength;
       end
       data.laterality(iNeuron,iRegion) = {info.laterality};
    end
end

%% Store info.
if ~isempty(Inputs.outputFile)
    fprintf('\nWriting %s..',Inputs.outputFile);
    save(Inputs.outputFile,'data');
    fprintf('\nDone!\n');
end

end

