swcfolder2 = '/groups/mousebrainmicro/mousebrainmicro/shared_tracing/Finished_Neurons/analysis/test'
myfiles2 = dir([swcfolder2,'/*.swc']);
gtswc = '/groups/mousebrainmicro/mousebrainmicro/shared_tracing/Finished_Neurons/analysis/test/2017-05-04_G-005_consensus.swc'
clear S
for j=1:length(myfiles2)%valinds
    %%
    j=2
    testswc = fullfile(swcfolder2,myfiles2(j).name);
    [status,cmdout] =unix(sprintf(...
        'java -jar %s/DiademMetric.jar -G %s -T %s -m true --xyPathThresh 100 -x %d',...
        fold,gtswc,testswc,100));
    [score,FN,FP] = parsecmdout(cmdout);
    S(j).path = myfiles2(j).name;
    S(j).score = score;
    S(j).FN = FN;
    S(j).FP = FP;
    [swcData] = loadSWC(testswc);
    S(j).swc = swcData(:,3:5);
    
    figure(100)
    cla
    hold on
    myplot3(swcDataGT(:,3:5),'m.')
    myplot3(S(2).swc,'go')
    myplot3(S(2).FN,'d')

end
%%
% check FN for that neuron
[swcDataGT] = loadSWC(gtswc);
%%
figure(100)
cla
hold on
myplot3(swcDataGT(:,3:5),'m.')
myplot3(S(2).swc,'go')
%
%
% myplot3(S(5).swc,'o')
myplot3(S(2).FN,'d')
% myplot3(S(2).FP,'s')
%%

legend('gt','base')
%%
for j=1:length(myfiles2)%valinds
    figure(10+j)
    cla
    myplot3(swcData(:,3:5),'.')
    hold on
    myplot3(S(j).swc,'o')
end











