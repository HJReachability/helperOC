function TTR = TD2TTR(g, TD, tau)
% TTR = TD2TTR(g, TD, tau)
% Converts a time-dependent value function to a time-to-reach value
% function
%
% Inputs:
%   g - grid structure
%   TD - time-dependent value function
%   tau - time stamps associated with TD
%
% Output:
%   TTR - time-to-reach value function

%% Input checking
if g.dim ~= length(size(TD)) - 1
  error(['Grid dimensions must be one less than dimension of ' ...
    'time-dependent value function!'])
end

if length(tau) ~= size(TD, g.dim+1)
  error(['Length of time stamps must be equal to length of ' ...
    'time-dependent value function!'])
end

%% Compute TTR
large = 1e6;
TTR = large*ones(g.N');

colons = repmat({':'}, 1, g.dim);
TTR(TD(colons{:}, 1) <= 0) = 0;

for i = 2:length(tau)
  TTR(TD(colons{:}, i) <= 0) = min(tau(i), TTR(TD(colons{:}, i) <= 0));
end

end