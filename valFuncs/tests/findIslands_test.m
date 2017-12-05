function findIslands_test()
%% Test in 2D
% Grid
g.dim = 2;
g.min = -ones(g.dim, 1);
g.max = ones(g.dim, 1);
g.N = [151; 151];
g.bdry = {@addGhostExtrapolate; @addGhostPeriodic};
g.max(2) = g.max(2) * (1 - 1 / g.N(2));
g = processGrid(g);

% Make two spheres
r1 = 0.3;
c1 = [0.3; 0.2];
data = shapeSphere(g, c1, r1);

r2 = 0.2;
c2 = [-0.2; 0.9];
data = min(data, shapeSphere(g, c2, r2));
data = min(data, shapeSphere(g, c2-[0; 2], r2));

% Find islands
tic
[isls, rNs, rs, cs] = findIslands(g, data);
toc

% Display stats
disp('Number of islands in 2D example')
disp(['  computed: ' num2str(length(isls)) ' | true: 2'])

r = [r1 r2];
c = [c1 c2];
for i = 1:length(isls)
  disp('Computed')
  disp(['  radius: (' num2str(rs{i}(1)) ', ' num2str(rs{i}(2)) ')'])
  disp(['  center: (' num2str(cs{i}(1)) ', ' num2str(cs{i}(2)) ')'])  
end

for i = 1:length(isls)
  disp('True')
  disp(['  radius: (' num2str(r(i)) ', ' num2str(r(i)) ')'])
  disp(['  center: (' num2str(c(1, i)) ', ' num2str(c(2, i)) ')'])
end

%% Test in 3D
% Grid
clear g
g.dim = 3;
g.min = -ones(g.dim, 1);
g.max = ones(g.dim, 1);
g.N = 101;
g.bdry = @addGhostPeriodic;
g = processGrid(g);

% Make two spheres
r1 = 0.2;
c1 = [-0.9; 0.2; -0.5];
data = shapeSphere(g, c1, r1);
data = min(data, shapeSphere(g, c1 + [2; 0; 0], r1));

r2 = 0.05;
c2 = [-0.2; 0.3; 0.5];
data = min(data, shapeSphere(g, c2, r2));

% Find islands
tic
[isls, rNs, rs, cs] = findIslands(g, data);
toc

% Display stats
disp('Number of islands in 3D example')
disp(['  computed: ' num2str(length(isls)) ' | true: 2'])

r = [r1 r2];
c = [c1 c2];

for i = 1:length(isls)
  disp('Computed')
  disp(['  radius: (' num2str(rs{i}(1)) ', ' num2str(rs{i}(2)) ', ' ...
    num2str(rs{i}(3)) ')'])
  disp(['  center: (' num2str(cs{i}(1)) ', ' num2str(cs{i}(2)) ', ' ...
    num2str(cs{i}(3)) ')'])  
end

for i = 1:length(isls)
  disp('True')
  disp(['  radius: (' num2str(r(i)) ', ' num2str(r(i)) ', ' num2str(r(i)) ')'])
  disp(['  center: (' num2str(c(1, i)) ', ' num2str(c(2, i)) ', ' ...
    num2str(c(3, i)) ')'])
end
end