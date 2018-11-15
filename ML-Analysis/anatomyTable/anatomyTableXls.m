function [] = anatomyTableXls(outputFile,cellNames, anatomyInfo, values,varargin)
%genAnatomyTableXls. generate anatomy overview table in xls format from
%provided anatomy information.
%% Parse input.
p = inputParser;
p.addRequired('outputFile',@(x) ischar(x));
p.addRequired('cellNames',@(x) ischar(x) | iscell(x) & size(x,1)==1);
p.addRequired('anatomyInfo',@(x) isstruct(x));
p.addRequired('values',@(x) isnumeric(x) || iscell(x));
p.addParameter('CollumnWidth',5,@(x) isnumeric(x) & length(x) ==1);
p.addParameter('LabelWidth',30,@(x) isnumeric(x) & length(x) ==1);
p.addParameter('ValueSize',18,@(x) isnumeric(x) & length(x) ==1);
p.addParameter('BackgroundColor',[0,0,0],@(x) isnumeric(x) & isequal(size(x),[1,3]));
p.addParameter('LabelColor',[1,1,1],@(x) isnumeric(x) & size(x,2)==3);
p.addParameter('Title','',@(x) ischar(x));
% parse.
p.parse(outputFile, cellNames, anatomyInfo, values, varargin{:});
Inputs = p.Results;
clear outputFile cellNames anatomyInfo values
if ischar(Inputs.cellNames), Inputs.cellNames={Inputs.cellNames}; end
if size(Inputs.values,1)~=size(Inputs.cellNames,2) ||...
        size(Inputs.values,2)~=size(Inputs.anatomyInfo,1)
    error('Size of values does not match number of cells and anatomy info');
end
if size(Inputs.LabelColor,1)>1 && size(Inputs.LabelColor,1)~=size(Inputs.cellNames,2)
    error('Number of provided label colors does not match number of provided cells');
end
%% Sort graph according to graph Order.
[~,ind] = sort([Inputs.anatomyInfo.graphOrder]);
Inputs.anatomyInfo = Inputs.anatomyInfo(ind);
Inputs.values = Inputs.values(:,ind);

%% Organize data into cell.
% Header.
resMat = [{''},{Inputs.anatomyInfo.safeName}];
% Cells + data.
if isnumeric(Inputs.values)
    temp = [Inputs.cellNames',num2cell(Inputs.values)];
else
    temp = [Inputs.cellNames',Inputs.values];
end
resMat = [resMat;temp];
resMat(1,1) = {Inputs.Title};
nRegions = size(Inputs.anatomyInfo,1);
nNeurons = size(Inputs.cellNames,2);

%% Write excel sheet
if ~isempty(dir(Inputs.outputFile)), delete(Inputs.outputFile); end
xlswrite(Inputs.outputFile,resMat);
% Connect to Excel
Excel = actxserver('excel.application');
% Get Workbook object
WB = Excel.Workbooks.Open(Inputs.outputFile,0,false);
try
% Set background header.
excelColor = @(x) (double(x(1)*255) * 256^0) + (double(x(2)*255) * 256^1) + (double(x(3)*255) * 256^2);
cCol = xlsColNum2Str(nRegions+4);
rangeStr = sprintf('A1:%s%i',cCol{:}, size(resMat,1));
WB.Worksheets(1).Item(1).Range(rangeStr).Interior.Color=excelColor(Inputs.BackgroundColor);
% Set collumns to anatomy colors.
for iRegion=1:nRegions
    cColLetter = xlsColNum2Str(iRegion+1); 
    cColLetter = cColLetter{:};
    color = hex2rgb(Inputs.anatomyInfo(iRegion).geometryColor);
%     C = (double(color(1)) * 256^0) + (double(color(2)) * 256^1) + (double(color(3)) * 256^2);
    WB.Worksheets(1).Item(1).Range(sprintf('%s1:%s%i',cColLetter,cColLetter,size(resMat,1))).Interior.Color=excelColor(color);
end
% header formatting
% Horizontal align all anatomical collumns
colLetter = xlsColNum2Str(size(resMat,2));
header = WB.Worksheets(1).Item(1).Range(sprintf('B1:%s1',colLetter{:}));
header.Cells.HorizontalAlignment=-4108;
header.ColumnWidth = Inputs.CollumnWidth;
header.Font.Size = 14;
header.Font.Bold = true;
header.Orientation = 45;
header.Borders.Item('xlEdgeBottom').LineStyle = 1;
header.Borders.Item('xlEdgeBottom').Weight = -4138;
% Markers formatting
markers = WB.Worksheets(1).Item(1).Range(sprintf('B2:%s%i',colLetter{:},size(resMat,1)));
markers.Font.Bold = true;
markers.Font.Size = Inputs.ValueSize;
markers.Cells.VerticalAlignment=-4108;
markers.Cells.HorizontalAlignment=-4108;
%cell names formatting.
rowNames = WB.Worksheets(1).Item(1).Range(sprintf('A1:A%i',size(resMat,1)));
rowNames.Font.Size = 14;
rowNames.Font.Bold = true;
rowNames.Font.Color = excelColor(Inputs.LabelColor(1,:));
rowNames.Cells.VerticalAlignment=-4108;
rowNames.Cells.HorizontalAlignment=-4108;
rowNames.ColumnWidth = Inputs.LabelWidth;
% Individual cell colors (if requested)
if size(Inputs.LabelColor,1)>1
    for iNeuron=1:nNeurons
       rangeStr = sprintf('A%i:A%i',iNeuron+1,iNeuron+1);
       rowNames = WB.Worksheets(1).Item(1).Range(rangeStr);
       rowNames.Font.Color = excelColor(Inputs.LabelColor(iNeuron,:));
    end
end
% format title.
title = WB.Worksheets(1).Item(1).Range('A1:A1');
title.Font.Size = 18;
title.Font.Bold = true;
title.Font.Color = excelColor([1,1,1]);
title.Cells.HorizontalAlignment=-4108;
% Save Workbook
WB.Save();
% Close Workbook
WB.Close();
% Quit Excel
Excel.Quit();
% Open.
winopen(Inputs.outputFile);
catch me
    % Close Workbook
    WB.Close();
    % Quit Excel
    Excel.Quit();
    rethrow(me);
end

end

