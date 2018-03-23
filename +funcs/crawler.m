function neurons = crawler(neuron_list)
% crawler
%% Read settings file.
[cFolder,~,~] = fileparts(which('writeNeuronSwc'));
jsonText = fileread(fullfile(cFolder,'settings.json'));
settings = jsondecode(jsonText);

%% populate neuron list properties
query = '{ swcTracings{ id tracingStructure{ name } neuron{ idString } } }';
[ response ] = callgraphql( settings.Database.TracingsUrl, query);
neuron_querry_list = [response.swcTracings(:).neuron];
numNeurons_in_repo = length(neuron_querry_list);
repo_dict = containers.Map;
for ineuron = 1:numNeurons_in_repo
    repo_tracing_response = response.swcTracings(ineuron);
    repo_dict(sprintf('%s-%s',repo_tracing_response.neuron.idString,repo_tracing_response.tracingStructure.name)) = repo_tracing_response.id;
end
keys = repo_dict.keys();
split_keys = regexp(keys, '-', 'split');
[neuron_repo_stringId,neuron_repo_type] = deal([]);
for it = 1:length(split_keys)
    neuron_repo_stringId{it} = split_keys{it}{1};
    neuron_repo_type{it} = split_keys{it}{2};
end
axon_indicies = find(contains(neuron_repo_type,'axon'));

%%
if isempty(neuron_list)
    neuron_list = unique(neuron_repo_stringId);
    querry_pids = containers.Map;
    for it = 1:length(axon_indicies)
        querry_pids(keys{axon_indicies(it)}) = repo_dict(keys{axon_indicies(it)});
    end
else
    querry_pids = containers.Map;
    for it = 1:length(neuron_list)
        querry_pids(keys{axon_indicies(it)}) = repo_dict(sprintf('%s-axon',neuron_list{it}));
    end
end

%% retrieve querries based on pids
neurons = [];
pids_keys = querry_pids.keys();
try parfor_progress(0);catch;end
parfor_progress(length(pids_keys));
for ikey = 1:length(pids_keys)
    parfor_progress;
    key = pids_keys{ikey};
    retrieved_axon = getTracingfromId( querry_pids(key),settings.Database.TracingsUrl);
    neurons{ikey}.name = key;
    neurons{ikey}.acronym = retrieved_axon(1).acronym;
    neurons{ikey}.soma = retrieved_axon(1);
    neurons{ikey}.recon = neuron2recon(retrieved_axon);
end
parfor_progress(0)

%%
% outargs = [];
% try parfor_progress(0);catch;end
% parfor_progress(numNeurons_in_repo)
% for ineuron = 1:numNeurons_in_repo
%     parfor_progress;
%     sprintf('%d out of %d',ineuron,numNeurons_in_repo)
%     neuron = getNeuronfromIdString(neuron_list{ineuron});
%     outargs{ineuron}.name = neuron_list{ineuron};
%     outargs{ineuron}.soma = neuron.axon(1);
% 
%     if recon
%         outargs{ineuron}.data = neuron2recon(neuron);
%     else
%         outargs{ineuron}.data = neuron;
%     end
%     save outargs ineuron outargs
% end
% parfor_progress(0)
end

function recons = neuron2recon(neuron)

clear recons
structure = neuron;
subs = [[structure.x]' [structure.y]' [structure.z]'];
numnodes = length(structure);
edges = [[1:numnodes]' [structure.parentNumber]'];
recons.edges = edges;
edges(any(edges==-1,2),:)=[];
A = sparse(edges(:,1),edges(:,2),1,numnodes,numnodes);
recons.A = A;
recons.subs = subs;

end