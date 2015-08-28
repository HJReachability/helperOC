% Script to create spheres in 2, 3, 4, and 6 dimensions. Requires level set
% toolbox.
clear

g = cell(4,1);
sphere = cell(4,1);

g{1}.dim = 2;
g{1}.min = -2*ones(g{1}.dim, 1);
g{1}.max = 2*ones(g{1}.dim, 1);
g{1}.bdry = @addGhostExtrapolate;
g{1}.N = 101;
g{1} = processGrid(g{1});
sphere{1} = shapeSphere(g{1});

g{2}.dim = 3;
g{2}.min = -2*ones(g{2}.dim, 1);
g{2}.max = 2*ones(g{2}.dim, 1);
g{2}.bdry = @addGhostExtrapolate;
g{2}.N = 51;
g{2} = processGrid(g{2});
sphere{2} = shapeSphere(g{2});

g{3}.dim = 4;
g{3}.min = -2*ones(g{3}.dim, 1);
g{3}.max = 2*ones(g{3}.dim, 1);
g{3}.bdry = @addGhostExtrapolate;
g{3}.N = 31;
g{3} = processGrid(g{3});
sphere{3} = shapeSphere(g{3});

g{4}.dim = 6;
g{4}.min = -2*ones(g{4}.dim, 1);
g{4}.max = 2*ones(g{4}.dim, 1);
g{4}.bdry = @addGhostExtrapolate;
g{4}.N = 17;
g{4} = processGrid(g{4});
sphere{4} = shapeSphere(g{4});

dims = [2 3 4 6];

save('spheres2346D')