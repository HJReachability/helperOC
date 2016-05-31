function [gIm, dataIm] = MIE2Implicit(gMIE, dataMIE, side, gTI)

if ~strcmp(side, 'lower') && ~strcmp(side, 'upper')
  error('side must be ''lower'' or ''upper''!')
end

%% Create full grid using MIE grid and terminal integrator grid
if nargin < 4
  gTI.dim = 1;
  gTI.N = 51;
  gTI.min = -10;
  gTI.max = 10;
  gTI.bdry = @addGhostExtrapolate;
end

gIm.dim = gTI.dim + gMIE.dim;
gIm.N = [gTI.N; gMIE.N];
gIm.min = [gTI.min; gMIE.min];
gIm.max = [gTI.max; gMIE.max];
gIm.bdry = gTI.bdry;
for i = 1:length(gMIE.bdry)
  gIm.bdry{end+1,1} = gMIE.bdry{i};
end
gIm = processGrid(gIm);

if nargout < 2
  return
end

%% Create implicit value function
% % Preprocess MIE value function
% switch gMIE.dim
%   case 1
%     dataMIE = dataMIE';
%   case 2
%     temp = zeros([1 size(dataMIE)]);
%     temp(1,:,:) = dataMIE;
%     dataMIE = temp;
%   case 3
%     temp = zeros([1 size(dataMIE)]);
%     temp(1,:,:,:) = dataMIE;
%     dataMIE = temp;
% end

if strcmp(side, 'lower')
%   dataIm = repmat(dataMIE, gIm.N(1), 1) - gIm.xs{1};
  dataIm = fillInMissingDims(gIm, dataMIE, 2:gIm.dim) - gIm.xs{1};
else
  dataIm = gIm.xs{1} - fillInMissingDims(gIm, dataMIE, 2:gIm.dim);
end

end