function genHeatMaps(cellList, anaList, outputFolder, varargin)
%% Parse input.
p = inputParser;
p.addRequired('cellList',@(x) (ischar(x) && length(x)==6) || iscell(cellList));
p.addRequired('anaList',@(x) ischar(x) || iscell(cellList));
p.addRequired('outputFolder',@(x) ischar(x));
p.addParameter('VoxelSize',[150,150,150],@(x) all(size(x) == [1,3]));
p.addParameter('VoxelDilation',0,@(x) isnumeric(x))
p.addParameter('StructureFilter',[0,1,5,6],@(x) isnumeric(x));
p.addParameter('ForceHemi','no',@(x) ischar(x));
p.addParameter('MeshFile',fullfile('//nrs/mouselight/Shared Files/Mesh Info/allenMesh.mat'),@(x) ischar(x));
p.parse(cellList, anaList, outputFolder,varargin{:});
Inputs = p.Results;

if ischar(Inputs.cellList), Inputs.cellList={Inputs.cellList}; end
if ischar(Inputs.anaList), Inputs.anaList={Inputs.cellList}; end
if ~isdir(Inputs.outputFolder), mkdir(Inputs.outputFolder); end
%% Load mesh
fprintf('\nLoading mesh file..');
load(Inputs.MeshFile);

%% Go through mask list.
for iAna = 1:size(Inputs.anaList,2)
    cAnaStr = sprintf('_%s',Inputs.anaList{iAna}{:});
    fprintf('\nHeatmap for: %s',cAnaStr);
    %% Create anatomy Mask.
    ontIm = VoxelizedBrainArea( Inputs.VoxelSize, Inputs.anaList{iAna}, allenMesh );
    %% Go through neurons.
    for iNeuron = 1:size(Inputs.cellList,1)
        cNeuron = Inputs.cellList{iNeuron,1};
        cNeuron = strrep(cNeuron,'''','');
        % Get heatmap.
        [ heatIm, ontIm ] = VoxelRegionHeatMap( cNeuron, Inputs.VoxelSize, ontIm, Inputs.VoxelDilation, Inputs.StructureFilter, Inputs.ForceHemi  );
        % Save matlab file.
        if ~isdir(fullfile(outputFolder,cAnaStr(2:end))),mkdir(fullfile(outputFolder,cAnaStr(2:end))); end
        matFile = fullfile(outputFolder,cAnaStr(2:end),sprintf('%s%s.mat',cNeuron,cAnaStr));
        save(matFile,'heatIm','ontIm');
        % save tiff
        tifFile = fullfile(Inputs.outputFolder,cAnaStr(2:end),sprintf('%s%s.tif',cNeuron, cAnaStr));
        tifIm = zeros(size(ontIm,2),size(ontIm,1),3,size(ontIm,3),'uint16');
        tifIm(:,:,1,:) = permute(heatIm,[2,1,4,3]);
        tifIm(:,:,3,:) = permute(ontIm.*100,[2,1,4,3]);
        options.color = true; 
        options.compress = 'no'; 
        options.message = false; 
        options.append = false; 
        options.overwrite = true; 
        options.big = false;
        saveastiff(tifIm,tifFile,options);
    end
end