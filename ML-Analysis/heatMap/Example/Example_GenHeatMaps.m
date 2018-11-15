%% File Parameters.
outputFolder = fullfile('C:\heatmap');
cellList = {'AA0010'};
anaList =  {{'caudoputamen'},{'isocortex'},{'caudoputamen','isocortex'}};

%% Call main function.
genHeatMaps(cellList,anaList,outputFolder,...
    'VoxelSize',[150,150,150],...
    'VoxelDilation',0,...
    'StructureFilter',[0,1,5,6],... % swc format
    'ForceHemi','right');
