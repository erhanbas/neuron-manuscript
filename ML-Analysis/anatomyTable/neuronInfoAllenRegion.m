function [info] = neuronInfoAllenRegion(neuron,cStructIdPath)
%neuronInfoAllenRegion. Takes structure 'neuron' from getNeuronfromIdString
% and a Allen structure path and return axonal info of that neuron for that
% structure.
halfPoint = 5695;
xSoma = neuron.axon(1).x;
info = [];
info.laterality = '';
info.bi.nBranches = 0;
info.bi.nEndPoints = 0;
info.bi.totalLength = 0;
info.ipsi = info.bi;
info.contra = info.bi;

structIdPaths = {neuron.axon.structureIdPath};
ind = cellfun(@(x) strfind(x,cStructIdPath),structIdPaths,'UniformOutput',false);
ind = cellfun(@(x) ~isempty(x),ind);
ind = find(ind);
if ~isempty(ind)
   % count branches/endpoints.
   structIdValues = [neuron.axon(ind).structureIdValue];
   info.bi.nBranches = sum(structIdValues==5);
   info.bi.nEndPoints = sum(structIdValues==6);
   % get length and laterality info..
   for iNode = 1:size(ind,2)
       cNode = neuron.axon(ind(iNode));
       if cNode.parentNumber>0
           pNode = neuron.axon(cNode.parentNumber);
           dist = sqrt((cNode.x - pNode.x)^2 + (cNode.y - pNode.y)^2 + (cNode.z - pNode.z)^2); 
           info.bi.totalLength = info.bi.totalLength + dist;
           % laterality info.
           if (cNode.x<halfPoint && xSoma<halfPoint) ||...
                   (cNode.x>=halfPoint && xSoma>=halfPoint)
               laterality = 'ipsi';
           else
               laterality = 'contra';
           end
           info.(laterality).totalLength = info.(laterality).totalLength + dist;
           if cNode.structureIdValue == 5
               info.(laterality).nBranches = info.(laterality).nBranches+1;
           end
           if cNode.structureIdValue == 6
               info.(laterality).nEndPoints = info.(laterality).nEndPoints+1;
           end
       end
   end
   % get laterality entire neuron.
   
   xCoords = [neuron.axon(ind).x];
   if (all(xCoords<halfPoint) && xSoma<halfPoint) ||...
           (all(xCoords>=halfPoint)&& xSoma>=halfPoint)
       info.laterality = 'I';
   elseif (all(xCoords<halfPoint) && xSoma>=halfPoint) ||...
           (all(xCoords>=halfPoint)&& xSoma<halfPoint)
       info.laterality = 'C';
   else
       info.laterality = 'B';
   end
end
end

