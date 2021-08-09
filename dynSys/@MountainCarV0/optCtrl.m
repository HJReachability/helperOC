function uOpt = optCtrl(obj, t, xs, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, deriv, uMode, dMode, MIEdims)

position = xs{1};
velocity = xs{2};
    
%% Input processing
if nargin < 5
  uMode = 'min';
end


%% https://github.com/ZhiqingXiao/OpenAIGymSolution/blob/master/MountainCar-v0_close_form/mountaincar_v0_close_form.ipynb 
%         position, velocity = observation
%         lb = min(-0.09 * (position + 0.25) ** 2 + 0.03,
%                 0.3 * (position + 0.9) ** 4 - 0.008)
%         ub = -0.07 * (position + 0.38) ** 2 + 0.07
%         if lb < velocity < ub:
%             action = 2 # push right
%         else:
%             action = 0 # push left

% TODO: Use deriv instead of hard-coded values above?
% TODO: not sure this is working... 


lb = min(-0.09 * (position + 0.25)^2 + 0.03, ...
       0.3 * (position + 0.9)^4 - 0.008);

ub = -0.07 * (position + 0.38)^2 + 0.07;

% action = 0; % push left
% if (lb < velocity) & (velocity < ub)
%   action = 2; % push right
% end
% TODO: handle uMode (always min for Backwards Reachability with goal)  

%% Optimal control
actions = zeros(size(xs{1}));
actions((lb < velocity) & (velocity < ub)) = 2;
uOpt = actions;

end