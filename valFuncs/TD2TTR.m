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
%
% Mo Chen, 2016-04-18

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
TTR = inf(g.N');

for i = 1:length(tau)
  % TTR(TD(:,:,:,i) <= 0) = 0; if i == 1
  % TTR(TD(:,:,:,i) <= 0) = min(tau(i), TTR(TD(:,:,:,i) <= 0)); otherwise
  eval(updateTTR_cmd(g.dim, 'i'));
end

end

function cmdStr = updateTTR_cmd(dims, indStr)
% TTR = updateTTR(TD, TTR, tau, i)
% Generates command to update TTR function

%% Generate command for updating TTR
% TTR(TD(:,:,:,i) <= 0)
cmdStr = ['TTR(' get_dataStr(dims, 'i', 'TD') ' <= 0)'];

if strcmp(indStr, '1')
  % TTR(TD(:,:,:,i) <= 0) = 0;
  cmdStr = cat(2, cmdStr, ' = 0;');
else
  % TTR(TD(:,:,:,i) <= 0) = min(tau(i), TTR(TD(:,:,:,i) <= 0));
  cmdStr = cat(2, cmdStr, [' = min(tau(i), ' cmdStr ');']);
end

end