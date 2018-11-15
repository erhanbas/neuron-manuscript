function viztsne(Y,names,neurons,env,neuron_color)
if nargin<5
    neuron_color=[];
else
    neuron_color(isnan(neuron_color))=0;
end
f=figure('renderer','painters','Color','k');
sp1 = subplot(1,2,1);
L = gscatter(Y(:,1),Y(:,2),names(:),neuron_color,[],20);
axis equal tight
ax = gca;
set(ax,'Color',[1 1 1]*.1)
% co = ax.XAxis.Color;
ax.XAxis.Color = [1 1 1];
ax.YAxis.Color = [1 1 1];

legend('off')
%apply mouse motion function
set(f,'windowbuttonmotionfcn',{@mousemove,L,neurons,env});

function mousemove(src,ev,L,neurons,env)

%since this is a figure callback, the first input is the figure handle:
f=src;
%like all callbacks, the second input, ev, isn't used. 
%determine which object is below the cursor:
obj=hittest(f); %<-- the important line in this demo
[lia,locb] = ismember(obj,L);
if lia %if over the plot...
    currloc = [obj.XData,obj.YData];
    %get cursor coordinates in its axes:
    subplot(1,2,1)
    hold on
    delete(findobj(gcf,'Marker','o'))
    circ = plot(currloc(1),currloc(2),'ro','MarkerSize',10);
    name = get(obj,'DisplayName');
    hold off
    title(name,'Color','w')
    % draw swc
    subplot(122)
    cla
    plot(env(:,1),env(:,2),'r-')
    hold on
    ineuron = locb;
    gplot3(neurons{ineuron}.recon.A,neurons{ineuron}.recon.subs);
    plot3(neurons{ineuron}.recon.subs(1,1),neurons{ineuron}.recon.subs(1,2),neurons{ineuron}.recon.subs(1,3),'ro','MarkerFaceColor','g')
    set(gca,'Ydir','Reverse')
    min_env = min(env);
    max_env = max(env);
   
%     view([0 90])
    axis equal off
    xlim([min_env(1)-10 max_env(1)+10])
    ylim([min_env(2)-10 max_env(2)+10])

    subplot(121)
else
    delete(findobj(f,'tag','mytooltip')); %delete last tool tip
 
end
 
 
function index=findclosestpoint2D(xclick,yclick,datasource)
%this function checks which point in the plotted line "datasource"
%is closest to the point specified by xclick/yclick. It's kind of 
%complicated, but this isn't really what this demo is about...
 
xdata=get(datasource,'xdata');
ydata=get(datasource,'ydata');
 
activegraph=get(datasource,'parent');
 
pos=getpixelposition(activegraph);
xlim=get(activegraph,'xlim');
ylim=get(activegraph,'ylim');
 
%make conversion factors, units to pixels:
xconvert=(xlim(2)-xlim(1))/pos(3);
yconvert=(ylim(2)-ylim(1))/pos(4);
 
Xclick=(xclick-xlim(1))/xconvert;
Yclick=(yclick-ylim(1))/yconvert;
 
Xdata=(xdata-xlim(1))/xconvert;
Ydata=(ydata-ylim(1))/yconvert;
 
Xdiff=Xdata-Xclick;
Ydiff=Ydata-Yclick;
 
distnce=sqrt(Xdiff.^2+Ydiff.^2);
 
index=distnce==min(distnce);
 
index=index(:); %make sure it's a column.
 
if sum(index)>1
    thispoint=find(distnce==min(distnce),1);
    index=false(size(distnce));
    index(thispoint)=true;
end