function [score,FN,FP] = parsecmdout(cmdout);
score = 0;
FN=[];
FP=[];
newlines = strfind(cmdout, sprintf('\n'));
% find double newlines
newlines = newlines(find(diff(newlines)==1));
% append end of the file
newlines(end+1) = length(cmdout);

str = 'Score: ';
st = strfind(cmdout,str)+length(str);
% read until first newline
score = str2double(cmdout(st:newlines(find(newlines>st,1))));

str = 'Nodes that were missed (position and weight):';
st = strfind(cmdout,str)+length(str)+1;
if ~isempty(st)
    pr = cmdout(st:newlines(find(newlines>st,1)));
    fr=strfind(pr,'(');
    ed=strfind(pr,')');
    FN = zeros(length(fr),3);
    for ii=1:length(fr)
        FN(ii,:) = (eval(['[',pr(fr(ii)+1:ed(ii)-1),']']));
    end
end

str = 'Extra nodes in test reconstruction (position and weight):';
st = strfind(cmdout,str)+length(str)+1;
if ~isempty(st)
    pr = cmdout(st:newlines(find(newlines>st,1)));
    fr=strfind(pr,'(');
    ed=strfind(pr,')');
    FP = zeros(length(fr),3);
    for ii=1:length(fr)
        FP(ii,:) = (eval(['[',pr(fr(ii)+1:ed(ii)-1),']']));
    end
end


