function getDendriteRot(neuronId)
%% Load neuron.
neuron = getNeuronfromIdString(neuronId,'Type','dendrite','ForceHemi','right');
%% Center neuron around soma.
swc = [[neuron.dendrite.sampleNumber]' [neuron.dendrite.structureIdValue]' [neuron.dendrite.x]' -[neuron.dendrite.y]'...
    [neuron.dendrite.z]' ones(size(neuron.dendrite,1),1) [neuron.dendrite.parentNumber]'];
for iDim = 3:5
   swc(:,iDim) = swc(:,iDim) - swc(1,iDim);
end
%% Plot
% figure
Handles = [];
Handles.hFig = figure('Color',[0,0,0],...
    'Position',[410,230,1024,805],...
    'Name',sprintf('Dendrite View: %s',neuronId),'NumberTitle','off');
Handles.hAx = axes('Color',[0,0,0]);
% dendrite.
dimLabels = {'X (\mum)','Y (\mum)','Z (\mum)'};
adj = zeros(max(swc(:,1)));
ind = find(swc(:,7)>0);
adj(sub2ind(size(adj),swc(ind,1),swc(ind,7))) = 1;
adj(sub2ind(size(adj),swc(ind,7),swc(ind,1))) = 1;
Handles.hPlot = gplot3(adj, swc(:,[3:5])); hold on
Handles.hPlotOri = gplot3(adj, swc(:,[3:5]),'Visible','off'); hold on % we use this to transform from.
% format.
Handles.hPlot.LineWidth = 1.5;
Handles.hAx.Color = [0,0,0];
Handles.hAx.XColor = [1,1,1]; Handles.hAx.YColor = [1,1,1]; Handles.hAx.ZColor = [1,1,1];
Handles.hAx.DataAspectRatio  = [1,1,1];
xlabel(dimLabels{1});ylabel(dimLabels{2});zlabel(dimLabels{3});
view(2)
%% Control window.
Handles.hFigCont = figure('Position',[1434,230,410,230],...
    'DockControls','off','MenuBar','none',...
    'Name','Rotation Controls','NumberTitle','off');
% x controls.
Handles.Slider = [];
Handles.Text = [];
yPos = [150,100,50];
labels = {'X Rotation (Degrees)','Y Rotation (Degrees)','Z Rotation (Degrees)'};
for i = 1:3
    uicontrol('Style','text','String',labels{i},'Position',[20,yPos(i)+20,300,20]);
    Handles.Slider = [Handles.Slider;uicontrol('Style','slider',...
        'Min',-359,'Max',359,'Value',0,...
        'SliderStep', [1/(360+359) , 10/(360+359) ],...
        'Position',[20,yPos(i),300,20])];
    Handles.Text = [Handles.Text; uicontrol('Style','edit',...
        'String','0',...
        'Position',[340,yPos(i),30,20])];
end
for i = 1:3
    % callbacks.
    Handles.Slider(i).Callback = {@changeRotVal,Handles,i};
    Handles.Text(i).Callback = {@changeRotVal,Handles,i};
end
% close requests
Handles.hFigCont.CloseRequestFcn = {@closeDendWin,Handles};
Handles.hFig.CloseRequestFcn = {@closeDendWin,Handles};
end

function changeRotVal(obj,event,Handles,dim)
% get value.
switch obj.Style
    case 'slider'
        value = round(obj.Value);
    case 'edit'
        value = round(str2double(obj.String));
end
% set new value.
Handles.Slider(dim).Value = value;
% set text.
Handles.Text(dim).String = num2str(value);
% rotate coordinates.
coords = [Handles.hPlotOri.XData',...
    Handles.hPlotOri.YData',...
    Handles.hPlotOri.ZData'];
  newCoords =  rotateCoordinates( coords,...
        Handles.Slider(1).Value,Handles.Slider(2).Value,Handles.Slider(3).Value );
% Change plot data.
    Handles.hPlot.XData = newCoords(:,1);
    Handles.hPlot.YData = newCoords(:,2);
    Handles.hPlot.ZData = newCoords(:,3);
end

function closeDendWin(obj,event,Handles)
    delete(Handles.hFigCont);
    delete(Handles.hFig);
end
