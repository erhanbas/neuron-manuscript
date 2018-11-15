function [ x, y, color, varargout] = getRegionMaskOutline( regionStr, dimSelection, sliceRange, binSize )
%getRegionMaskOutline Gives region mask outline based on online Allen CCF
%   Detailed explanation goes here

% sliceRange = [6500,7000]; %in um

if nargin==3
    binSize = 25;
end
%% Lookup region info.       
regionId = getAllenStructIdfromName(regionStr);
info = getAllenAreaInfo(regionId);
color = hex2rgb(info.geometryColor);

%% Load region info allen
ccfUrl = 'http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/structure_masks/';
fileUrl = sprintf('%sstructure_masks_%i/structure_%i.nrrd',ccfUrl,binSize,regionId);
tempFile = websave(fullfile(tempdir,sprintf('structure_%i.nrrd',regionId)),fileUrl);
I = nrrdreadAllen(tempFile);
delete(tempFile);
I = permute(I,[3,1,2]);

% slice.
sliceDim = find(~ismember([1,2,3],dimSelection));
I = permute(I,[dimSelection(2),dimSelection(1),sliceDim]);
sliceRangePix = round(sliceRange/binSize);
if sliceRangePix(1)==0, sliceRangePix(1)=1; end
Imax = max(I(:,:,sliceRangePix(1):sliceRangePix(2)),[],3);
% Empty contour. check range
if sum(sum(Imax)) == 0
    [signalInd ] = find(I);
    [~,~,zInd] = ind2sub(size(I),signalInd);
    error('Contour was empty\nExpected slice value between %i and %i',min(zInd)*binSize,max(zInd)*binSize); 
end
% See how connected compnents there are in the image
[L,numComp] = bwlabeln(Imax);
x = cell(numComp,1);
y = cell(numComp,1);
for iComp = 1:numComp
    % get perimeter
    Ip = bwperim(L==iComp);
    % Trace.
    [i,j] = find(Ip==1,1);
    [contour,~] = TRACE_MooreNeighbourhood(Ip,[i,j]);
    x(iComp) = {contour(:,2)*binSize};
    y(iComp) = {contour(:,1)*binSize};
end
varargout{1} = regionId;
end
