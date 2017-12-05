function unitCircle()
% unitCircle()
%
% Plots an implicit surface function for the unit disk

%% Grid and function
N = 101;
X = linspace(-1.5, 1.5, N);
Y = linspace(-1.5, 1.5, N);
[x,y] = ndgrid(X,Y);

V = sqrt(x.^2 + y.^2) - 1;

%% Plot surface of function
f = figure;
s = surf(x,y,V);
s.FaceAlpha = 0.5;
s.LineStyle = 'none';
hold on

%% Plot unit circle
theta = linspace(0, 2*pi, 100);
x = cos(theta);
y = sin(theta);
z = zeros(size(x));
p = plot3(x,y,z);
p.Color = 'r';
p.LineWidth = 3;

% axis labels
xlabel('x')
ylabel('y')

% savefig(f, sprintf('%s.fig', mfilename), 'compact')
% export_fig(sprintf('%s', mfilename), '-pdf', '-transparent')
end