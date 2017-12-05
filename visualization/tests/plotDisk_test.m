function plotDisk_test()
% plotDisk_test()

t = linspace(0, 4*pi, 100);
r = linspace(0, 1, 100);

x = r.*cos(t);
y = r.*sin(t);

figure
for i = 1:length(t)
  plotDisk([x(i) y(i)], r(i), 'r--');
  
  xlim([-2 2])
  ylim([-2 2])

  drawnow
end

end