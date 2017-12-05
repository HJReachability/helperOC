function plotControls(obj)
% plotControls(obj)
%
% Plots the control input history of the vehicle
% 
% Opens a new figure window!
%
% Mo Chen, 2016-02-01

figure;
numPlots = obj.nu;
spC = ceil(sqrt(numPlots));
spR = ceil(numPlots/spC);
for i = 1:obj.nu
  subplot(spC, spR, i)
  plot(obj.uhist(i,:));
  title(['u_' num2str(i)])
end

end