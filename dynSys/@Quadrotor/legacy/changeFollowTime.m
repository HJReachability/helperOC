function [ u, x, tau1 ] = changeFollowTime (obj, tau0)
%------------
% UNUSED
%-------------

% Request to change following/separation time to the vehicle in the front 
% to tau0 seconds. 
% tau0          requested new following time
% u             control sequence used
% x             state trajectory followed
% tau1          actual new following time



% Choose tau1 in tauSet closest to tau0
safetyLevels = obj.safeV.hor.V.label(2:end);
[ ~, idx ] = min ( abs(safetyLevels - tau0) );
tau1 = safetyLevels(idx);
fprintf(sprintf('Requested new follow time %d sec, actual new follow time %d sec.', tau0, tau1));

% Increase or decrease in separation time?
if tau1 == obj.tau
    disp ('No change in follow time performed.');
    return;
end


% Find the set S of feasible states with safetyLevel >= tau1 and <=
% tau1+0.5 (only if tau1 < 3.0) 
SIdx1 = obj.safeV.hor.V.data(:,idx+1)>0;
if idx < length(obj.safeV.hor.V.label)-1
    SIdx2 = obj.safeV.hor.V.data(:,idx+2)<0;
    SIdx = SIdx1 & SIdx2;
else
    SIdx = SIdx1;
end
dx = zeros(length(obj.safeV.hor.g.dx{1}(:)),safeV.hor.g.dim);
S = zeros(sum(SIdx),safeV.hor.g.dim);
for i = 1:safeV.hor.g.dim
    dx(:,i) = obj.safeV.hor.g.dx{i}(:);
    S(:,i) = dx(SIdx,i);
end


% Current state X0. If set S is non empty, find state X1 in S that minimizes |X1-X0|^2
X1 = zeros(obj.nx, 1);
X0_1 = obj.x(1 : safeV.hor.g.dim);
[~, idx1] = min( sum((S - repmat(X0_1',[size(S,1),1])) .^ 2, 2) );
X1(1:safeV.hor.g.dim) = S(idx1,:)';
X0_2 = obj.x(safeV.hor.g.dim+1 : 2*safeV.hor.g.dim);
[~, idx2] = min( sum((S - repmat(X0_2',[size(S,1),1])) .^ 2, 2) );
X1(safeV.hor.g.dim+1 : 2*safeV.hor.g.dim) = S(idx2,:)';
X1(end-1:end) = obj.x(end-1:end);


% While safe, move to X1
u = trackTraj(obj, [obj.x,X1], traj_t, t0, T);

% Update vehicle state


end