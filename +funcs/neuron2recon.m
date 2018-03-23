function recons = neuron2recon(neurons)

clear recons
parfor_progress(numNeurons);
parfor ineuron = 1:numNeurons
    structure = neurons(ineuron).axon;
    subs = [[structure.x]' [structure.y]' [structure.z]'];
    numnodes = length(structure);
    edges = [[1:numnodes]' [structure.parentNumber]'];
    recons(ineuron).edges = edges;
    edges(any(edges==-1,2),:)=[];
    A = sparse(edges(:,1),edges(:,2),1,numnodes,numnodes);
%     recons(ineuron).name = ;
    recons(ineuron).A = A;
    recons(ineuron).subs = subs;
    parfor_progress;
end
parfor_progress(0);

end