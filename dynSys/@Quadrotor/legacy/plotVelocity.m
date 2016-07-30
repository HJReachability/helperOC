function plotVelocity(obj, color)
% function plotVelocity(obj, color)
%
% Plots the current velocity and velocity trajectory of the quadrotor
% 
% Inputs:  obj   - current quadrotor object
%          color - color of plotting (defaults to blue)
%
% Mo Chen, 2015-05-24

if nargin<2, color = 'b'; end

vdim = obj.vdim;

% Plot velocity trajectory; update plot if it already exists
if isempty(obj.hvxvyhist) || ~isvalid(obj.hvxvyhist)
    obj.hvxvyhist = plot(obj.xhist(vdim(1),:), obj.xhist(vdim(2),:), ':', 'color', color); hold on
else
    obj.hvxvyhist.XData = obj.xhist(vdim(1),:); 
    obj.hvxvyhist.YData = obj.xhist(vdim(2),:); 
end

% Plot current; update plot if it already exists
if isempty(obj.hvxvy) || ~isvalid(obj.hvxvy)
    obj.hvxvy = plot(obj.x(vdim(1),:), obj.x(vdim(2),:), 'o', 'color', color); hold on
else
    obj.hvxvy.XData = obj.x(vdim(1)); 
    obj.hvxvy.YData = obj.x(vdim(2));
end

end