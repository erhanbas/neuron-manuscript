function [pd,keynodes] = getKeyPd(recon,type)
A = recon.A;
subs = recon.subs;
soma = find(sum(A,2)==0);
% regular = A==1;
junction = find(sum(A)>1);
tip=find(sum(A,1)==0);
keynodes = unique([soma,junction,tip]);
if nargin<2 | isempty(type)
    pd = pdist(subs(keynodes,:));
elseif type=='geo'
    % geo dist
    G = graph(A,'lower');
    pdall = distances(G);
    pd = pdall(keynodes,:);
    pd = pd(:,keynodes);
    pd = pd(tril(ones(size(pd)),-1)>0);
    pd = pd(:)';
else
    error('unknow type, choices: [] or ''geo''')
end

