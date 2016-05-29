function vf = reconMIE(vfs_MIE, range_lower, range_upper)
% vf = reconMIE(vfs_MIE, range_lower, range_upper)
%
% Inputs:
%   vfs_MIE - MIE value functions
%              .g:      common grid
%              .tau:    common time vector
%              .datas:  cell structure of MIE datas (value function look-up
%                       tables
%              .senses: cell structure of data senses ('lower' or
%                       'upper')
%              .TIdims: terminal integrator dimensions (cell vector)
%     eg. Dubins car with x and y as terminal integrators
%         vfs_MIE.g:      1D periodic grid in theta dimension
%                .datas:  {data_xl; data_xu; data_yl; data_yu}
%                .senses: {'lower'; 'upper'; 'lower'; 'upper'}
%                .TIdims: [1; 1; 2; 2]
%
%   range_lower - lower range of computation domain
%   range_upper - upper range of computation domain
%     (by default, lower and upper ranges are chosen to be within a few
%     grid points of the state x)
%
% Output:
%   vf    - value function within the computation range
%             (by default, the computation range is within a neighborhood
%             of the state x)
%             .g
%             .data
%             .tau
%
% Mo Chen, 2016-05-14

%% Input checking
% Computation range
if ~isvector(range_lower) || ~isvector(range_upper)
  error('Lower and upper ranges must be vectors!')
end

if numel(range_lower) ~= numel(range_upper)
  error('Dimension of lower and upper ranges do not agree!')
end

if any(range_upper <= range_lower)
  error('Upper range must be strictly greater than lower range!')
end

% Terminal integrator dimensions
TIdims = unique(vfs_MIE.TIdims);
for i = 1:max(TIdims)
  if TIdims(i) ~= i
    error('Missing terminal integrator dimension!')
  end
end

full_dim = length(range_lower);
if full_dim ~= max(TIdims) + vfs_MIE.g.dim
  error('Dimension of computation range is inconsistent!')
end

vf.tau = vf_MIE.tau;
end