function [color,structureId] = areaName2Color(areaName)

structureId = nan(1,length(areaName));
color = nan(length(areaName),3);
for idx = 1:length(areaName)
    sprintf('%d out of %d',idx,length(areaName))
    if isempty(areaName{idx});continue;end
    testpath = areaName{idx}.structureIdPath;
    inds = strsplit(deblank(strrep(testpath,'/',' ')),' ');
    structureId(idx) = str2double(inds{end});
    info = getAllenAreaInfo(structureId(idx));
    color(idx,:) = hex2rgb(info.geometryColor);
end