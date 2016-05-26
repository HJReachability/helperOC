function dataStr = get_dataStr(dims, indStr, varName)
% dataStr = get_dataStr(dims, indStr, varName)
%
% Outputs the string varName(:,:,indStr) where ':,' repeats dims number of
% times
%
% Mo Chen, 2016-04-18

if nargin < 3
  varName = 'data';
end

dataStr = [varName '('];
for j = 1:dims
  dataStr = cat(2, dataStr, ':,');
end
dataStr = cat(2, dataStr, [indStr ')']);

end