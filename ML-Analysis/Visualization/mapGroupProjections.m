function [] = mapGroupProjections(neuronGroups,anatomyLoc, outputFile, varargin)
%mapGroupProjections. Maps groups of neurons onto a anatomical location(s)
%in binary way with specified coloring and voxel size. Reads in heatmaps
%generates by genHeatMaps.
%% Parse input.
p = inputParser;
p.addRequired('neuronGroups',@(x) iscell(x) && size(x,1)==1);
p.addRequired('anatomyLoc',@(x) iscell(x) || ischar(x));
p.addRequired('outputFile',@(x) ischar(x));
p.addParameter('groupColor',[],@(x) isnumeric(x) && size(x,2)==3);
p.addParameter('DilationSize',20,@(x) isnumeric(x) && length(x)==1);
p.addParameter('DilationStructure','disk',@(x) ischar(x));
p.addParameter('VoxelSize',[10,10,10],@(x) isnumeric(x) && isequal(size(x),[1,3]));
p.addParameter('MeshFile',fullfile('//nrs/mouselight/Shared Files/Mesh Info/allenMesh.mat'),@(x) ischar(x));
p.parse(neuronGroups,anatomyLoc, outputFile, varargin{:});
Inputs = p.Results;
clear neuronGroups anatomyLoc outputFile 
% default values.
nGroups = size(Inputs.neuronGroups,2);
if isempty(Inputs.groupColor), Inputs.groupColor = jet(nGroups); end
if ischar(Inputs.anatomyLoc), Inputs.anatomyLoc = {Inputs.anatomyLoc}; end

%% Load mesh
fprintf('\nLoading mesh file..');
load(Inputs.MeshFile);

%% Mask of anatomy.
ontIm = VoxelizedBrainArea( Inputs.VoxelSize, Inputs.anatomyLoc, allenMesh );

%% Go throught Groups.
for iGroup = 1:nGroups
   cGroup = Inputs.neuronGroups{iGroup}; 
   nNeurons = size(cGroup,2);
   groupIm = zeros(size(ontIm));
   fprintf('\nGroup %i\\%i',iGroup,nGroups);
   for iNeuron=1:nNeurons
      cNeuron = cGroup{iNeuron};
      fprintf('\nNeuron %s [%i\\%i]',cNeuron,iNeuron,nNeurons);
      % Load neuron.
      neuron = getNeuronfromIdString(cNeuron,'Type','axon','ForceHemi','right');
      % Map coordinates.
      tempIm = zeros(size(ontIm),'logical');
      coords =[[neuron.axon.x]',[neuron.axon.y]',[neuron.axon.z]'];
      pixPos = round(coords./Inputs.VoxelSize);
      pixInd = sub2ind(size(tempIm),pixPos(:,1),pixPos(:,2),pixPos(:,3));
      tempIm(pixInd) = true;
      % Dilate.
      se = strel(Inputs.DilationStructure,Inputs.DilationSize);
      tempIm = imdilate(tempIm,se);
      groupIm = groupIm+tempIm;
   end
      figure
   imshow(max(groupIm(:,:,600:800)>1,[],3),[]);
   
      figure
   imshow(max(groupIm(:,:,600:800),[],3),[]);

end

end