clear all
% crawler
% run L-measure tool
% outside of matlab, use java code
% % load L-measure result
% lmeasurepath = '/groups/mousebrainmicro/home/base/CODE/MATLAB/pipeline/manuscript/swcrepo/Lscore';
% [feats_Lmeasure,neuronnames_Lmeasure,featnames_Lmeasure] = funcs.load_Lmeasure(lmeasurepath);addpath(genpath('./matlab_dbqueries'))
addpath(genpath('common'))

region = 'whole Brain';
% rundate = '180319'
rundate=['180419']
matfolder='matfiles';
mkdir(matfolder)

% you can also retrieve any neuron with funcs.crawler(neuron_list),
% e.g. funcs.crawler({'AA0001','AA0002'}). passing empty array will return
% everything
if rundate
    load(fullfile(matfolder,sprintf('recons-%s.mat',rundate)))
else
    neurons = funcs.crawler([]); % will return all axons in the repo.
    numneurons = length(neurons);
    [neuron_list,areaName] = deal([]);
    for in = 1:numneurons
        neuron_list{in} = [neurons{in}.name(1:6),'-',neurons{in}.acronym];
        areaName{in}.safeName = neurons{in}.soma.safeName;
        areaName{in}.structureIdPath = neurons{in}.soma.structureIdPath;
    end
    [allen_neuron_color,structureId] = funcs.areaName2Color(areaName);
    
    % envelope
    sliceRange = [6500,7000]; dimSelection = [1 2];
    [ env, color, varargout] = funcs.getMask( region, dimSelection, sliceRange );
    
    rundate = datestr(now,'yymmdd');
    save(fullfile(matfolder,sprintf('recons-%s.mat',datestr(now,'yymmdd'))))
end

%%
% pdist measure
if rundate
    load(fullfile(matfolder,sprintf('feats-%s.mat',rundate)))
else
    feats_Dists = getPdDist(neurons);
    feats_Dists_geo = getPdDist(neurons,'geo');
    save(fullfile(matfolder,sprintf('feats-%s.mat',datestr(now,'yymmdd'))))
end

%%
close all
[Y_dist_tsne,loss_Y_dist_tsne] = tsne(feats_Dists,'Algorithm','exact','Distance','spearman');
funcs.viztsne(Y_dist_tsne,neuron_list,neurons,env,allen_neuron_color)
set(gcf,'Name','dist-spear-tsne')
[Y_dist_tsne,loss_Y_dist_tsne] = tsne(feats_Dists,'Algorithm','exact','Distance','spearman','Standardize',1);
funcs.viztsne(Y_dist_tsne,neuron_list,neurons,env,allen_neuron_color)
set(gcf,'Name','dist-spear-tsne')
[Y_dist_tsne,loss_Y_dist_tsne] = tsne(feats_Dists,'Algorithm','exact','Distance','spearman','Perplexity',5);
funcs.viztsne(Y_dist_tsne,neuron_list,neurons,env,allen_neuron_color)
set(gcf,'Name','dist-spear-tsne')
[Y_dist_tsne,loss_Y_dist_tsne] = tsne(feats_Dists,'Algorithm','exact','Distance','spearman','Standardize',1,'Perplexity',5);
funcs.viztsne(Y_dist_tsne,neuron_list,neurons,env,allen_neuron_color)
set(gcf,'Name','dist-spear-tsne')

%% BELOW is for debugging/experimental
if 0
    [Y_distEmd_tsne,loss_Y_distEmd_tsne] = tsne(feats_Dists,'Algorithm','exact','Distance',@distEmd);
    funcs.viztsne(Y_distEmd_tsne,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','Y_distEmd_tsne')
    
    [Y_distChi2_tsne,loss_Y_distChi2_tsne] = tsne(feats_Dists,'Algorithm','exact','Distance',@distChiSq);
    funcs.viztsne(Y_distEmd_tsne,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','Y_distChi2_tsne')
    
    %%
    % close all
    [Y_geodist_tsne,loss_Y_geodist_tsne] = tsne(feats_Dists_geo,'Algorithm','exact','Distance','spearman');
    funcs.viztsne(Y_geodist_tsne,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','geodist-spear-tsne')
    
    [Y_geodistEmd_tsne,loss_Y_geodistEmd_tsne] = tsne(feats_Dists_geo,'Algorithm','exact','Distance',@distEmd);
    funcs.viztsne(Y_geodistEmd_tsne,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','Y_geodistEmd_tsne')
    
    [Y_geodistChi2_tsne,loss_Y_geodistChi2_tsne] = tsne(feats_Dists_geo,'Algorithm','exact','Distance',@distChiSq);
    funcs.viztsne(Y_geodistChi2_tsne,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','Y_geodistChi2_tsne')
    
    %%
    D_dist = squareform(pdist(feats_Dists));
    D_dist_geo = squareform(pdist(feats_Dists_geo));
    
    D_dist_spear = squareform(pdist(feats_Dists,'spearman'));
    D_dist_geo_spear = squareform(pdist(feats_Dists_geo,'spearman'));
    
    D_dist_emd = (pdist2_(feats_Dists,feats_Dists,'emd'));
    D_dist_geo_emd = (pdist2_(feats_Dists_geo,feats_Dists_geo,'emd'));
    
    D_dist_chisq = (pdist2_(feats_Dists,feats_Dists,'chisq'));
    D_dist_geo_chisq = (pdist2_(feats_Dists_geo,feats_Dists_geo,'chisq'));
    
    % D_lmeasure = squareform(pdist(feats_Lmeasure,'spearman'));
    
    %%
    close all
    [Y_dist_lle] = lle(feats_Dists',10,3);Y_dist_lle=Y_dist_lle';
    funcs.viztsne(Y_dist_lle,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','dist-lle')
    
    [Y_geodist_lle] = lle(feats_Dists_geo',10,3);Y_geodist_lle=Y_geodist_lle';
    funcs.viztsne(Y_geodist_lle,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','geodist-lle')
    
    
    % [Y_lmeasure_cmd,eigvals_lmeasure] = cmdscale(D_lmeasure);
    % funcs.viztsne(Y_lmeasure_cmd,neuronnames_Lmeasure,recons,env)
    % set(gcf,'Name','lmeasure-cmd')
    
    % [Y_dist_tsne,loss_dist] = tsne(feats_Dists_geo,'Algorithm','exact','Distance','spearman');
    % funcs.viztsne(Y_dist_tsne,neuron_list,recons,env,allen_neuron_color)
    % set(gcf,'Name','dist-tsne')
    %%
    close all
    [Y_dist_cmd,eigvals_dist] = cmdscale(D_dist,2);
    funcs.viztsne(Y_dist_cmd,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','dist-cmd')
    
    [Y_dist_emd_cmd,eigvals_dist] = cmdscale(D_dist_emd);
    funcs.viztsne(Y_dist_emd_cmd,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','Y_dist_emd_cmd')
    
    [Y_dist_chisq_cmd,eigvals_dist] = cmdscale(D_dist_chisq);
    funcs.viztsne(Y_dist_chisq_cmd,neuron_list,neurons,env,allen_neuron_color)
    set(gcf,'Name','Y_dist_chisq_cmd')
    
    % [Y_dist_md,eigvals_dist] = mdscale(D_dist,2);
    % funcs.viztsne(Y_dist_md,neuron_list,recons,env,allen_neuron_color)
    % set(gcf,'Name','dist-md')
    
    % [Y_geodist_cmd,eigvals_dist] = cmdscale(D_dist_geo);
    % funcs.viztsne(Y_geodist_cmd,neuron_list,recons,env,allen_neuron_color)
    % set(gcf,'Name','geo-dist-cmd')
    
    % [Y_geodist_md,eigvals_dist] = mdscale(D_dist_geo,2);
    % funcs.viztsne(Y_geodist_md,neuron_list,recons,env,allen_neuron_color)
    % set(gcf,'Name','geodist-md')
    
    %%
    [Y_geodist_tsne,loss_dist] = tsne(feats_Dists_geo,'Algorithm','exact','Distance','spearman');
    funcs.viztsne(Y_geodist_tsne,neuron_list,recons,env,allen_neuron_color)
    set(gcf,'Name','dist-tsne')
    
    %%
    
    
    
    %%
    close all
    [Y,loss2] = tsne(featLmeasure,'Algorithm','exact','Distance','spearman')
    % D = pdist(feats,'spearman');
    % [Y,eigvals] = cmdscale(D);
    funcs.viztsne(Y,neuronnames,recons,env)
    
    %%
    % % save recons recons
    %%
    % [ha, pos] = tight_subplot(3,2,[.01 .03],[.1 .01],[.01 .01])
    % for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
    % set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
    
    % screen ratio: 16x9
    screen_ratio = [16 9]
    grid_config = floor(numNeurons/prod(screen_ratio))*screen_ratio;
    
    close all
    fig = figure;
    [ha, pos] = tight_subplot(grid_config(1),grid_config(1),[.0 .0],[.1 .01],[.01 .01]);
    for ineuron = 1:10%numNeurons
        %isub(ineuron) = subplot(20,20,ineuron);
        axes(ha(ineuron));
        gplot3(recons(ineuron).A,recons(ineuron).subs);
        view([0 90])
        axis equal off
    end
    set(ha(1:prod(grid_config)-grid_config(1)),'XTickLabel',''); set(ha,'YTickLabel','')
    %% write as swcs
    mkdir('swcrepo')
    for ineuron = 1:numNeurons
        if 0
            structure = neuron(ineuron).axon;
            subs = [[structure.x]' [structure.y]' [structure.z]'];
            numnodes = length(structure);
            edges = [[1:numnodes]' [structure.parentNumber]'];
        else
            edges = recons(ineuron).edges;
            subs = recons(ineuron).subs;
        end
        
        % Standardized swc files (www.neuromorpho.org) -
        % 0 - undefined
        % 1 - soma
        % 2 - axon
        % 3 - (basal) dendrite
        % 4 - apical dendrite
        % 5+ - custom
        numnodes = size(subs,1);
        swcdata = ones(numnodes,7);
        swcdata(:,1) = edges(:,1);
        swcdata(:,7) = edges(:,2);
        swcdata(:,3:5) = subs;
        swcdata(:,2) = 2;
        swcdata(1,2) = 1;
        
        % save swc
        filename = fullfile('./swcrepo',sprintf('%s-axon.swc',neurons{ineuron}))
        fid = fopen(filename,'w');
        fprintf(fid,'%d %d %f %f %f %d %d\n',swcdata');
        fclose(fid);
        
    end
    
    
    
    
    
end

