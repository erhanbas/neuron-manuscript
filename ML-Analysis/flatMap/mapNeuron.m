function [outputData,varargout]=mapNeuron(idString,varargin)
%% Parse input.
p = inputParser;
p.addRequired('idString',@(x) ischar(x) && length(x)==6);
p.addParameter('Type','axon',@(x) ischar(x));
p.addParameter('Color','depth',@(x) ischar(x) ||( ismatrix(x) && all(size(x)==[1,3])));
p.addParameter('ForceHemi','no',@(x) ischar(x));
p.addParameter('HFig',[],@(x) ishandle(x) || isempty(x));
p.addParameter('Output',true,@(x) islogical(x));
p.parse(idString,varargin{:});
Inputs = p.Results;

Settings.VoxelSize = [10,10,10];
%% Load neuron from database.
fprintf('\nLoading neuron: %s',Inputs.idString);
neuron = getNeuronfromIdString(Inputs.idString,'ForceHemi',Inputs.ForceHemi);

%% Load pre-generated flat map.
fprintf('\nLoading Laplacian Info');
[cFolder,~,~] = fileparts(which('mapNeuron'));
load(fullfile('//nrs/mouselight/Shared Files/flatMap/lap10.mat')); % load lap and metalap
lap(lap==0)=NaN('single');
Param = load(fullfile(cFolder,'precalculated','calc_param.mat')); % load lap and metalap
%% Load precalculated anatomy map.
load(fullfile(cFolder,'precalculated','anatomyFlatMap.mat')); % load resIm and cMap

%% Points to Pix. (LAPLACIAN DIM ORDER Y,Z,X)
% transform matrix.
tMat = eye(4,4);
for iDim=1:3
    tMat(iDim,iDim) = 1/Settings.VoxelSize(iDim);
end
swc = [[neuron.(Inputs.Type).sampleNumber]' [neuron.(Inputs.Type).structureIdValue]' [neuron.(Inputs.Type).y]' [neuron.(Inputs.Type).z]' [neuron.(Inputs.Type).x]' ones(size(neuron.(Inputs.Type),1),1) [neuron.(Inputs.Type).parentNumber]'];
% get indices in laplacian matrix.
pixPoints = round([swc(:,3:5),zeros(size(swc,1),1)]*tMat);
pixPoints = pixPoints(:,1:3);
indPix = sub2ind(size(lap),pixPoints(:,1),pixPoints(:,2),pixPoints(:,3));
% Filter for nodes on cortex.
indHit = find(~isnan(lap(indPix)));
swc = swc(indHit,:);
indPix = indPix(indHit,:);
pixPoints = pixPoints(indHit,:);

%% Process per hemisphere for symmetry.
swcHemi = [];
swcHemi.left = [];
swcHemi.right = [];
for iHemi = {'left','right'}
    % Select nodes on hemisphere.
    switch iHemi{:}
        case 'left'
            nodeList = find(swc(:,5)>5695);
        case 'right'
            nodeList = find(swc(:,5)<=5695);
    end
    %% Point to flatmap
    fprintf('\nTransforming points for %s hemisphere',iHemi{:});
    for iNode = 1:size(nodeList,1)
        cNode = nodeList(iNode);
        switch iHemi{:}
            case 'left'
                [ xr, yr,zr ] = transformAllenPix2Flat( pixPoints(cNode,1), pixPoints(cNode,2), size(lap,3)-pixPoints(cNode,3),... % you do mimus the total X lenngth because the direction of the dimenions is reversed (low is left hemisphere and high is right hemisphere)
                        Param.coeff1, Param.coeff2, Param.points3d, lap);
                                    xr = (-xr );
            case 'right'
                [ xr, yr,zr ] = transformAllenPix2Flat( pixPoints(cNode,1), pixPoints(cNode,2), pixPoints(cNode,3),...
                        Param.coeff1, Param.coeff2, Param.points3d, lap);             

            end
        swcHemi.(iHemi{:}) = [ swcHemi.(iHemi{:}) ; swc(cNode,1:2) xr, yr,zr, swc(cNode,6:7) ];
    end
    if ~isempty(swcHemi.(iHemi{:}))
        %% reformat swc info.
        swcHemi.(iHemi{:})(:,8) = swcHemi.(iHemi{:})(:,1); %store original node Id.
        swcHemi.(iHemi{:})(:,1) = [1:size(swcHemi.(iHemi{:}),1)]';
        for iNode = 1:size(swcHemi.(iHemi{:}),1)
           ind = find(swcHemi.(iHemi{:})(:,8) == swcHemi.(iHemi{:})(iNode,7));
           if ~isempty(ind)
            swcHemi.(iHemi{:})(iNode,7) = swcHemi.(iHemi{:})(ind,1);
           else
               swcHemi.(iHemi{:})(iNode,7) =-1;
           end
        end
    end
end
%% plot.
    depthMap = jet(10001);
if Inputs.Output
    if isempty(Inputs.HFig) 
        Inputs.HFig = figure;
    else
        clf(Inputs.HFig);
    end        
    hAx = axes;
    hAx.DataAspectRatio = [1,1,1];
    imshow(resIm,R,[1,730],'ColorMap',cMap);hold on;
    hAx.YDir = 'normal';
    xlabel('Left-Right axis');
    ylabel('Posterior-Anterior axis');
end
mappedData = [];
for iHemi = {'left','right'}
    if ~isempty(swcHemi.(iHemi{:}))
        if strcmpi(Inputs.Color,'depth')
            colorCode = depthMap(uint16(swcHemi.(iHemi{:})(:,5)+5000)+1,:);
        else
            colorCode = Inputs.Color;
        end
         if Inputs.Output
             scatter(swcHemi.(iHemi{:})(:,3),swcHemi.(iHemi{:})(:,4),10,colorCode,'filled');
         end
         mappedData = cat(1,mappedData,swcHemi.(iHemi{:})(:,[3:5,8]));
    end
end


%% Prep Output.
outputData = swc;
outputData(mappedData(:,4),3:5) = mappedData(:,1:3); % place new coordinates in old swc format.
fprintf('\nDone!\n');
varargout{1} = Inputs.HFig;
end

