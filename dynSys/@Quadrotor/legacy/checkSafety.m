function [safe, uSafe, valuex] = checkSafety(obj, safeV)
% THIS SHOULD NO LONGER BE NEEDED WITH THE NEW isSafe FUNCTION!
%
% function [safe, uSafe, valuex] = checkSafety(obj, safeV)
%
% Checks the safety of the current vehicle w.r.t. all vehicles in the list
% obj.sList, which contains a pointer to all vehicles with whom safety
% needs to be checked. Safety will be checked via evaluating the value
% functions contained in the cell structure safeV. If safeV is not a cell
% structure but just a single value function, then the same value function
% will be used to check the safety w.r.t. all other vehicles
%
% Returns a 1xN vector indicating safety, a obj.nu x N vector of control 
% actions, and a 1xN vector containing the safety values.
%
% Inputs:  obj    - current vehicle object
%          safeV  - safety value function(s)
% 
% Outputs: safe   - safety indicators
%          uSafe  - safety controls
%          valuex - safety values
%
% Mo Chen, 2015-07-22

warning('This should no longer be needed with the new isSafe function!')

% If safeV is not a cell structure, duplicate it and put it in a cell
% structure of the same size as obj.vList
if ~iscell(safeV)
  safeV = repmat({safeV}, size(obj.sList));
end

% Initialize outputs
safe = zeros(1, length(obj.sList));
uSafe = cell(1, length(obj.sList));
valuex = zeros(1, length(obj.sList));

% Compute outputs
for i = 1:length(obj.sList)
  [safe(i), uSafe{i}, valuex(i)] = isSafe(obj, obj.sList{i}, safeV{i});
end

end