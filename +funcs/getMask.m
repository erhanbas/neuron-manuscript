function [ env, color, varargout] = getMask( regionStr, dimSelection, sliceRange, binSize )
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
% find the largest area
Imax = max(I,[],3);
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
env = [x{1}(:) y{1}(:)];
varargout{1} = regionId;
end

function [ rgb ] = hex2rgb(hex,range)
% hex2rgb converts hex color values to rgb arrays on the range 0 to 1. 
% 
% 
% * * * * * * * * * * * * * * * * * * * * 
% SYNTAX:
% rgb = hex2rgb(hex) returns rgb color values in an n x 3 array. Values are
%                    scaled from 0 to 1 by default. 
%                    
% rgb = hex2rgb(hex,256) returns RGB values scaled from 0 to 255. 
% 
% 
% * * * * * * * * * * * * * * * * * * * * 
% EXAMPLES: 
% 
% myrgbvalue = hex2rgb('#334D66')
%    = 0.2000    0.3020    0.4000
% 
% 
% myrgbvalue = hex2rgb('334D66')  % <-the # sign is optional 
%    = 0.2000    0.3020    0.4000
% 
%
% myRGBvalue = hex2rgb('#334D66',256)
%    = 51    77   102
% 
% 
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myrgbvalues = hex2rgb(myhexvalues)
%    =   0.2000    0.3020    0.4000
%        0.5020    0.6000    0.7020
%        0.8000    0.6000    0.2000
%        0.2000    0.2000    0.9020
% 
% 
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myRGBvalues = hex2rgb(myhexvalues,256)
%    =   51    77   102
%       128   153   179
%       204   153    51
%        51    51   230
% 
% HexValsAsACharacterArray = {'#334D66';'#8099B3';'#CC9933';'#3333E6'}; 
% rgbvals = hex2rgb(HexValsAsACharacterArray)
% 
% * * * * * * * * * * * * * * * * * * * * 
% Chad A. Greene, April 2014
%
% Updated August 2014: Functionality remains exactly the same, but it's a
% little more efficient and more robust. Thanks to Stephen Cobeldick for
% the improvement tips. In this update, the documentation now shows that
% the range may be set to 256. This is more intuitive than the previous
% style, which scaled values from 0 to 255 with range set to 255.  Now you
% can enter 256 or 255 for the range, and the answer will be the same--rgb
% values scaled from 0 to 255. Function now also accepts character arrays
% as input. 
% 
% * * * * * * * * * * * * * * * * * * * * 
% See also rgb2hex, dec2hex, hex2num, and ColorSpec. 
% 

%% Input checks:

assert(nargin>0&nargin<3,'hex2rgb function must have one or two inputs.') 

if nargin==2
    assert(isscalar(range)==1,'Range must be a scalar, either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end

%% Tweak inputs if necessary: 

if iscell(hex)
    assert(isvector(hex)==1,'Unexpected dimensions of input hex values.')
    
    % In case cell array elements are separated by a comma instead of a
    % semicolon, reshape hex:
    if isrow(hex)
        hex = hex'; 
    end
    
    % If input is cell, convert to matrix: 
    hex = cell2mat(hex);
end

if strcmpi(hex(1,1),'#')
    hex(:,1) = [];
end

if nargin == 1
    range = 1; 
end

%% Convert from hex to rgb: 

switch range
    case 1
        rgb = reshape(sscanf(hex.','%2x'),3,[]).'/255;

    case {255,256}
        rgb = reshape(sscanf(hex.','%2x'),3,[]).';
    
    otherwise
        error('Range must be either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end

end


