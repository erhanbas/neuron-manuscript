# flatMap
Toolbox for performing cortical unfolding.

## Usage:  
    projPntCoords = flatMap('AA0100')  
Shows results of flat projection and outputs xyz coordinates of transformed points.  
### Optional parameters.  
 * 'Type': string, axon/dendrite  
 * 'Color': 3X1 rgb array [0-1], or 'depth' to color according to depth  
 * 'Output':	bool, shows results or not.
# heatMap
Toolbox for generating heatmaps of axons within anatomical structure.
## Usage
	genHeatMaps({'AA0010'},{{'pons'},{'caudoputamen','isocortex}}, 'C:\output');
### Optional Parameters
 * 'VoxelSize', [150,150,150], Voxel size in um
 * "VoxelDilation', 0, dilation of anatomical area's in pixels
 * 'StructureFilter', [0,1,5,6], type of SWC nodes to include
 * 'ForceHemi', 'no',force tracing to be projected on to certian hemsphere ('left' or 'right')
 * 'MeshFile', '//nrs/mouselight/Shared Files/Mesh Info/allenMesh.mat', location of allen mesh file
 