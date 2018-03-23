function [featLmeasure,neuronnames,featnames] = load_Lmeasure(lmeasurepath)
fid = fopen(lmeasurepath,'r');
vec = [];
neuronnames = {};
featnames = {};
while 1
    tline = fgetl(fid); %# read line by line
    cells = strsplit(tline,'\t');
    if length(cells)~=9, break, end
    % get rid of any pre/pos space
    vec(end+1) = str2double(deblank(cells{3}));
    [~,neuronnames{end+1},~] = fileparts(deblank(cells{1}));
    [~,featnames{end+1},~] = fileparts(deblank(cells{2}));
end
fclose(fid);

neuronnames = unique(neuronnames,'stable');
numneurons = length(neuronnames);
neuronnames = reshape(neuronnames,numneurons,1);

numfeats = length(vec)/numneurons;
featnames = featnames(1:numfeats);
featLmeasure = reshape(vec(:),[],numneurons)';
