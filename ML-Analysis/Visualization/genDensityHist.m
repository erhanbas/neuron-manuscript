function [ hFig, data ] = genDensityHist( mainFolder,anaMask, neuronIds,varargin )
%genDendityHist. Generate density histogram from generated heatmaps.
%% Parse input.
p = inputParser;
p.addRequired('mainFolder',@(x)ischar(x));
p.addRequired('anaMask',@(x) ischar(x));
p.addRequired('neuronIds',@(x) iscell(x) || ischar(x));
p.addParameter('BinSize',25,@(x) isnumeric(x) & length(x)==1);
p.addParameter('MaxValue',2000);
p.addParameter('Title','',@(x) ischar(x));
p.addParameter('Normalized',false,@(x) islogical(x));
p.addParameter('YLim',[],@(x) isnumeric(x) & isequal(size(x),[1,2]));
p.addParameter('Color',[1,0,0],@(x) isnumeric(x) & isequal(size(x),[1,3]));
p.addParameter('ErrorProperties',{},@(x) iscell(x) && isequal(size(x),[1,2]));
p.parse(mainFolder,anaMask, neuronIds,varargin{:});
Inputs = p.Results;

if ischar(Inputs.neuronIds), Inputs.neuronIds={Inputs.neuronIds}; end
nNeurons = size(Inputs.neuronIds,2);
bank = {};
%% Collect density data.
for iNeuron = 1:nNeurons
   cNeuron = Inputs.neuronIds{iNeuron};
   % Load heatmap.
   heatmapFile = fullfile(mainFolder,Inputs.anaMask,sprintf('%s_%s.mat',cNeuron,Inputs.anaMask));
   if isempty(dir(heatmapFile)), error('Could not find %s',heatmapFile); end
   load(heatmapFile);
   % get density numbers.
   heatIm = heatIm(heatIm>0);
   bank = [bank;{heatIm}];   
end
%% Bin data.
histBank = zeros(floor(Inputs.MaxValue/Inputs.BinSize)+1,nNeurons);
for iNeuron=1:nNeurons
    count=1;
   for lowLim=0:Inputs.BinSize:Inputs.MaxValue-Inputs.BinSize
      cBank = bank{iNeuron};
      histBank(count,iNeuron) = mean(cBank(cBank>=lowLim & cBank<lowLim+Inputs.BinSize));
            
      if Inputs.Normalized
        histBank(count,iNeuron) = (sum(cBank>=lowLim & cBank<lowLim+Inputs.BinSize)/size(cBank,1))*100; %NORMALIZED
      else
          histBank(count,iNeuron) = sum(cBank>=lowLim & cBank<lowLim+Inputs.BinSize); %Count
      end
      count = count+1;
   end
   histBank(count,iNeuron) = sum(cBank>(lowLim+Inputs.BinSize));
end
%% Get histogram values.
data = [];
data.avg = mean(histBank,2);
data.std = std(histBank,[],2);
data.sem = data.std/sqrt(nNeurons);
data.xPos = (Inputs.BinSize/2):Inputs.BinSize:(Inputs.BinSize/2)+Inputs.BinSize*size(data.avg,1)-1;
%% Plot.
hFig = figure('Color',[0,0,0]);
hAx = axes;
% scatter(data.xPos,data.avg,20,Inputs.Color,'filled'); hold on
hError = errorbar(data.xPos,data.avg,data.sem);
hError.Color = Inputs.Color; hError.MarkerSize = 5; hError.LineWidth = 1.5;
hError.LineStyle = 'none'; hError.Marker = 'o'; hError.MarkerFaceColor = Inputs.Color;
if ~isempty(Inputs.ErrorProperties)
    set(hError,Inputs.ErrorProperties{1},Inputs.ErrorProperties{2});
end
hAx.XColor = [1,1,1]; hAx.YColor = [1,1,1];hAx.TickDir = 'out';
hAx.Color = [0,0,0]; hAx.Box='off';
xlim([0,max(data.xPos)+(Inputs.BinSize/2)]);
if ~isempty(Inputs.YLim), ylim(Inputs.YLim); end
xlabel('Voxel Density (\mum per voxel)'); 
if Inputs.Normalized
    ylabel('Occurence (%)');
else
    ylabel('Count');
end
title(Inputs.Title,'Color',hAx.XColor);
fprintf('\n');
end

