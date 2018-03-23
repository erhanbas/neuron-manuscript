swcfolder = '/groups/mousebrainmicro/mousebrainmicro/shared_tracing/Finished_Neurons/analysis'
myfile = dir([swcfolder,'/*.swc']);

if 1
    neuronlist = {}
    iter=0
    neuron(1:100)=cell(1);
    neuronG(1:100)=cell(1);
    for ii=1:100;neuron{ii}{1}=0;end
    for ii=1:100;neuronG{ii}{1}=0;end
    
    for i=1:length(myfile)
        swcfilepath = fullfile(swcfolder,myfile(i).name);
        [~,swcfile] = fileparts(myfile(i).name);
        [name] = strsplit(swcfile,'_');
        
        [swcData,offset,color, header] = loadSWC(swcfilepath);
        swcData(:,3:5) = swcData(:,3:5) + ones(size(swcData,1),1)*offset;
        
        % edges
        edges = swcData(:,[1 7]);
        edges(any(edges==-1,2),:) = [];
        if isempty(edges)
            E=[];
        else
            E = sparse(edges(:,1),edges(:,2),1,max(edges(:)),max(edges(:)));
        end
        conn = max(E,E');
        
        
        % check if it exists
        if any(cellfun(@(x) strcmp(x,name{2}),neuronlist))
            idx = find(cellfun(@(x) strcmp(x,name{2}),neuronlist));
            if strcmp(name{end},'consensus')
                neuron{idx}{1} = swcData;
                neuronG{idx}{1} = conn;
            else
                neuron{idx}{length(neuron{idx})+1} = swcData;
                neuronG{idx}{length(neuronG{idx})+1} = conn;
            end
        else
            neuronlist{end+1} = name{2};
            iter=iter+1;
            if strcmp(name{end},'consensus')
                neuron{iter}{1} = swcData;
                neuronG{iter}{1} = conn;
            else
                neuron{iter}{length(neuron{iter})+1} = swcData;
                neuronG{iter}{length(neuronG{iter})+1} = conn;
            end
        end
    end
    save neuron neuron neuronG
else
    load('neuron')
end

%% parse inputs
swcfolder = '/groups/mousebrainmicro/mousebrainmicro/shared_tracing/Finished_Neurons/analysis';
myfolds = dir([swcfolder]);
myfolds=myfolds(~ismember({myfolds.name},{'.','..'}));
fold = '/groups/mousebrainmicro/home/base/Desktop/diademMetric';
users={'consensus','AZ','PB','CA','MW','BD','DR','GB'}

DM = cell(length(myfolds),length(users));
for ii=1:size(DM,1)+1
    for jj=1:size(DM,2)
        DM{ii,jj} = -1;
    end
end
DM(1,:)=users;
for i=1:length(myfolds)
    %%
    swcfoldpath = fullfile(swcfolder,myfolds(i).name);
    myfiles = dir([swcfoldpath,'/*.swc']);
    conidx = find(~cellfun(@isempty,(cellfun(@(x) strfind(x,'consensus'),{myfiles.name},'UniformOutput',false))));
    valinds = setdiff(1:length(myfiles),conidx);
    GTswc  = fullfile(swcfoldpath,myfiles(conidx).name);
    if 0
        %%
        % [swcData,offset,color, header] = loadSWC(GTswc);
        % swcData(:,3:5) = swcData(:,3:5) + ones(size(swcData,1),1)*offset;
        [swcData] = loadSWC(GTswc);
        swcData(:,6)=round(swcData(:,6));
        % write back
        fid = fopen(GTswc,'w')
        fprintf(fid,'%d %d %f %f %f %d %d\n',swcData')
        fclose(fid)
    end
    
    %%
    for j=1:length(myfiles)%valinds
        testswc = fullfile(swcfoldpath,myfiles(j).name);
        if 0
            % [swcData,offset,color, header] = loadSWC(testsec);
            % swcData(:,3:5) = swcData(:,3:5) + ones(size(swcData,1),1)*offset;
            [swcData] = loadSWC(testsec);
            swcData(:,6)=round(swcData(:,6));
            % write back
            fid = fopen(testsec,'w');
            fprintf(fid,'%d %d %f %f %f %d %d\n',swcData');
            fclose(fid);
        end
        %         GTswc='/groups/mousebrainmicro/mousebrainmicro/shared_tracing/Finished_Neurons/analysis/2017-04-19_G-016/2017-04-19_G-016_BD.swc'
        [status,cmdout] =unix(sprintf('java -jar %s/DiademMetric.jar -G %s -T %s -m true -x %d',fold,GTswc,testswc,10));
        [score,FN,FP] = parsecmdout(cmdout);
        
        % check user
        [~,fn] = fileparts(myfiles(j).name);
        fn=strsplit(fn,'_');
        IndexC = strfind(users, fn{end});
        Index = find(not(cellfun('isempty', IndexC)));
        
        if ~isempty(score)
            if Index==1
                DM{i+1,Index} = fn{2};
            else
                DM{i+1,Index} = (round(100*(score)));
            end
        end
        
        if (score)<5
            %%
            % stats
            [XGT,CGT,Xt,Ct] = X_G(GTswc,testswc);
            pDGT = squareform(pdist(XGT));
            pDGT = pDGT.*double(CGT);
            pDt = squareform(pdist(Xt));
            pDt = pDt.*double(Ct);
            
            % find FN paths
            if ~isempty(FN)
                [vals,inds] = min(pdist2(XGT(:,3:5),FN),[],2);
                missinginds = find(vals<1);
                totalmissingGTpath = sum(sum(pDGT(missinginds,:)));
            else
                totalmissingGTpath = 0;
            end
            
            if ~isempty(FP)
                [i j]
                % find FP paths
                [vals,inds] = min(pdist2(Xt(:,3:5),FP),[],2);
                extrainds = find(vals<1);
                totalextratpath = sum(sum(pDt(extrainds,:)));
            else
                totalextratpath = 0
            end
            
            totalGTnodes = size(XGT,1);
            totaltnodes = size(Xt,1);
            totalFPnodes = size(FP,1);
            totalFNnodes = size(FN,1);
            totalGTpathlength = sum(pDGT(:))/2;
            totaltpathlength = sum(pDt(:))/2;
            totalGTFNpathlength = totalmissingGTpath;
            totaltFPpathlength = totalextratpath;
            
            stats{i,Index} = full([totalGTnodes totaltnodes totalFNnodes totalFPnodes totalGTpathlength totaltpathlength totalGTFNpathlength totaltFPpathlength]);
            %             figure(33)
            %             gplot3(CGT,XGT(:,3:5),'-')
            %             hold on
            %             gplot3(Ct,Xt(:,3:5),'r-')
            %
        end
    end
    DM
end
%%
ST = zeros(size(stats,1),size(stats,2),8);
for i=1:size(stats,1)
    for j=1:size(stats,2)
        if ~isempty(stats{i,j})
            ST(i,j,:) = stats{i,j};
        end
    end
end
%%
% generate mask
mask = [zeros(size(ST,1),1) double(cell2mat(DM(2:end,2:end))>0)];
tag = {'totalGTnodes','totaltnodes','totalFNnodes','totalFPnodes','totalGTpathlength','totaltpathlength','totalGTFNpathlength','totaltFPpathlength'}
st_=[]
yy=[];
XX=[];
for i=1:size(ST,3)
    xx=ST(:,:,i).*mask;
    xx=xx(xx>0);
    XX=[XX;xx(:)];
    yy=cat(1,yy,repmat(tag(i),length(xx),1));
%     yy=[yy;ones(length(xx),1)*i];

    %     yy{i} = tag{i};
    hold on
    st_(i,:) = [min(xx) median(xx) max(xx)];
end
st_
figure(3)
boxplot(XX,yy)
%%
[st_(7)/st_(5) st_(8)/st_(6)]
%%
cell2mat(DM(2:end,:))
%%
idNeu = 5;
numAnn = length(neuron{idNeu});
figure(1),clf
for ii = 4%1:numAnn
    gplot3(neuronG{idNeu}{ii},neuron{idNeu}{ii}(:,3:5),'-')
    hold on
end

%%


%%
if 0
    [swcData,offset,color, header] = loadSWC(swcfile);
    swcData(:,3:5) = swcData(:,3:5) + ones(size(swcData,1),1)*offset;
    swcData(:,3:5) = swcData(:,3:5)*scale;
end












