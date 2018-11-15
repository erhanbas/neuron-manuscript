function [hFig,hAx] = pwDistanceMatrix(cellNames,pwDistMat, varargin)
%pwDistanceMatrix. generates 
%% Parse input.
p = inputParser;
p.addRequired('cellNames',@(x) iscell(x) && size(x,1)==1);
p.addRequired('pwDistMat',@(x) isnumeric(x) && issymmetric(x));
p.addParameter('LabelColors',[1,1,1],@(x) isnumeric(x));
p.addParameter('ColorMap','jet',@(x) ischar(x));
p.addParameter('Range',[],@(x) isnumeric(x));
p.addParameter('Title','',@(x) ischar(x));
p.parse(cellNames,pwDistMat, varargin{:});
Inputs = p.Results;
clear cellNames pwDistMat

nNeurons = size(Inputs.cellNames,2);
%% Configure axes.
hFig = figure('Color',[0,0,0]);
hAx = axes; hold on
hAx.Color = [0,0,0];
hAx.XColor = [1,1,1];
hAx.YColor = [1,1,1];
hAx.TickDir = 'out';
xlim([0,nNeurons]);
ylim([0,nNeurons]);
hAx.XTick = 0.5:1:nNeurons;
hAx.YTick = 0.5:1:nNeurons;
hAx.DataAspectRatio = [1,1,1];
    hAx.XTickLabelRotation = 45;
    
%% Tick Labels.
for iNeuron = 1:nNeurons
    if size(Inputs.LabelColors,1)>1
        cColor = Inputs.LabelColors(end - (iNeuron-1),:);
    else
        cColor = Inputs.LabelColors;
    end
    labelStr = {sprintf('\\color[rgb]{%f, %f, %f}%s',...
        cColor,Inputs.cellNames{end - (iNeuron-1)})};
    hAx.XTickLabel(end-(iNeuron-1)) = labelStr;
    hAx.YTickLabel(end-(iNeuron-1)) = labelStr;
end

%% show image. 
Im = imresize(Inputs.pwDistMat,100,'nearest');
RI = imref2d(size(Im),[0,nNeurons],[0,nNeurons]);
imshow(Im,RI,Inputs.Range);

%% Colorbar.
hBar = colorbar;
hBar.Color = [1,1,1];
hBar.TickDirection = 'out';
hBar.TicksMode
hBar.FontSize=12;
colormap(hAx,Inputs.ColorMap);
ylabel(hBar,'Jaccard Distance');

%% Title.
if ~isempty(Inputs.Title)
    hTitle= title(Inputs.Title);
    hTitle.Color = [1,1,1];
    hTitle.FontSize = 18;

end
end
