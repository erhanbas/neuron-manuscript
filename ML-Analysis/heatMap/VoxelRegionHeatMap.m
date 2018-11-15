function [ heatIm, ontIm ] = VoxelRegionHeatMap( neuronId, voxelSize, ontIm, voxelDilation, structureFilter, forceHemi  )
%% Dilate.
voxelDilation = ceil(voxelDilation);
if voxelDilation>0
    se = strel('sphere',voxelDilation);
    ontIm = imdilate(ontIm,se);
end

%% Load neuron.
fprintf('\nLoading neuron %s',neuronId);
[ neuron ] = getNeuronfromIdString( neuronId,'ForceHemi',forceHemi );

%% Downsample.
swcData = [[neuron.axon.sampleNumber]',[neuron.axon.structureIdValue]',...
    [neuron.axon.x]',[neuron.axon.y]',[neuron.axon.z]',...
    ones(size([neuron.axon.y]',1),1), [neuron.axon.parentNumber]'];
[swc] = upsampleSWC(swcData,1);
swc(:,4) = zeros(size(swc,1),1);
% lookup original structurevalue
for iNode = 1:size(swcData,1)
    if swcData(iNode,2)~=0
        [~,ind] = ismember(swcData(iNode,3:5),swc(:,(1:3)),'rows');
        if ind~=0
           swc(ind,4) = swcData(iNode,2);
        end
    end
end

%% Calculate heatmap.
heatIm = zeros(size(ontIm),'uint16');
for iNode =1:size(swc,1)
    if ismember(swc(iNode,4),structureFilter) && ~isnan(swc(iNode,1))
        xPos = ceil(swc(iNode,1)/voxelSize(1));
        yPos = ceil(swc(iNode,2)/voxelSize(2));
        zPos = ceil(swc(iNode,3)/voxelSize(3));
        if all([xPos,yPos,zPos]>0) && ...
                size(ontIm,1)>=xPos && size(ontIm,2)>=yPos && size(ontIm,3)>=zPos
            if ontIm(xPos,yPos,zPos) 
                heatIm(xPos,yPos,zPos) = heatIm(xPos,yPos,zPos) +1;
            end
        end
    end
end


end

