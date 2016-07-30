function [safe, uSafe, valuex] = isSafe(obj, others, safeV)
% function [safe, uSafe, valuex] = isSafe(obj, other, safeV)
%
% Checks whether this vehicle is safe within a time horizon of t with
% respect to the other vehicle
%
% Inputs:  obj    - this vehicle
%          others - other vehicles with whom safety should be checked; this
%                   should be a n x 1 or 1 x n cell
%                   all vehicles need to be of the same type so that a
%                   single safeV can be used
%          safeV  - safety reachable set value function
%
% Outputs: safe   - boolean array indicating whether this vehicle is safe
%                   with respect to the others
%          uSafe  - the optimal safe controllers
%          valuex - the values of levelset function
% Dynamics (6D):
%    \dot{p}_{x,r}   = v_{x,r}
%    \dot{v}_{x,r}   = obj.u_x - other.u_x
%    \dot{v}_{x,obj} = obj.u_x
%    \dot{p}_{y,r}   = v_{y,r}
%    \dot{v}_{y,r}   = obj.u_y - other.u_y
%    \dot{v}_{y,obj} = obj.u_y
% In 4D, the 3rd and 6th states are ommitted
%
% Mo Chen, 2015-05-23
% Modified: Qie Hu, 2015-07-01
% Modified: Mo Chen, 2015-07-21
% Modified: Kene Akametalu, 2015-07-21
% Modified: Mo Chen, 2015-10-19

% Check input
others = checkVehiclesList(others, 'quadrotor');

% Initialize outputs
safe = false(1, length(others));
uSafe = zeros(obj.nu, length(others));
valuex = -inf(1, length(others));

% Go through the other vehicles
for i = 1:length(others)
  % A vehicle is always safe with respect to itself
  if (obj == others{i})
    safe(i) = true;
    valuex(i) = inf;
    return
  end

  % Check safety for a single vehicle
  [safe(i), uSafe(:,i), valuex(i)] = isSafeSingle(obj, others{i}, safeV);
end
end

function [safe, uSafe, valuex] = isSafeSingle(obj, other, safeV)
% function [safe, uSafe, valuex] = isSafeSingle(obj, other, safeV)
%
% Thin wrapper function for calling the appropriate safety check functions
% depending on the dimension of the input grid.
%
% Mo Chen, 2015-10-22

if safeV.g.dim == 3
  [safe, uSafe, valuex] = isSafe3D(obj, other, safeV);
elseif safeV.g.dim == 2
  [safe, uSafe, valuex] = isSafe2D(obj, other, safeV);
else
  error('Safety value function must be 2 or 3D!')
end
end

function [safe, uSafe, valuex] = isSafe3D(obj, other, safeV)
% function [safe, uSafe, valuex] = isSafe3D(obj, other, safeV)
%
% Safety check in the case where two 3D reachable sets are being combined
% into a 6D reachable set
%
% Mo Chen, 2015-10-19

% Unpack reachable set data
tau = safeV.tau;
dataC = safeV.dataC;
dataS = safeV.dataS;
g = safeV.g;

% States in 6D reachable set
xr = obj.x(1) - other.x(1);
vxr = obj.x(2) - other.x(2);
vx = obj.x(2);
yr = obj.x(3) - other.x(3);
vyr = obj.x(4) - other.x(4);
vy = obj.x(4);
x = [xr vxr vx yr vyr vy];

% If the state is more than a grid point away from the computation domain,
% then the relative system is safe
if any(x' <= [g.min+g.dx; g.min+g.dx])
  safe = 1;
  uSafe = [];
  valueCx = max(dataC(:));
  valuex = valueCx;
  return
end

if any(x' >= [g.max-g.dx; g.max-g.dx])
  safe = 1;
  uSafe = [];
  valueCx = max(dataC(:));
  valuex = valueCx;
  return
end

% Compute value at current state
% Value according to collision criterion
valueCx = recon2x3D(tau, g, dataC, g, dataC, x, obj.tauInt);

% Value according to velocity limit criterion
ind = min(length(tau), find(tau<=t,1,'last')+1);
valueSxx = eval_u(g, dataS(:,:,:,ind), x(1:3));
valueSxy = eval_u(g, dataS(:,:,:,ind), x(4:6));
valueSx = min(valueSxx, valueSxy);

% Minimum value is safety value
valuex = min(valueCx, valueSx);

% Is the value safe?
if valuex <= 0
  safe = false;
else
  safe = true;
end

% Compute gradient of V(t,x) where t is the first t such that V(t,x) <= 0
[~, ~, g6D, valueC, ~, ind] = recon2x3D(tau, g, dataC, g, dataC, x, t);
valueSSx = eval_u(g, dataS(:,:,:,ind), [g6D.xs{1}(:) g6D.xs{2}(:) g6D.xs{3}(:)]);
valueSSy = eval_u(g, dataS(:,:,:,ind), [g6D.xs{4}(:) g6D.xs{5}(:) g6D.xs{6}(:)]);
valueS = min(valueSSx, valueSSy);
valueS = reshape(valueS, g6D.shape);
value = min(valueC, valueS);

% Convert to signed distance function for fair comparison of the two
% criteria (using default [medium] accuracy for faster speed)
% Get rid of this?
valuesd = signedDistanceIterative(g6D, value,'low');

% Now we can finally read off gradient (Using first order derivative for
% speed)
gradsd = extractCostates(g6D, valuesd,'low');
gradx = calculateCostate(g6D, gradsd, x);

% Compute optimal safe controller
uSafe = [...
  (gradx(2)+gradx(3)>=0)*obj.uMax + (gradx(2)+gradx(3)<0)*obj.uMin; ...
  (gradx(5)+gradx(6)>=0)*obj.uMax + (gradx(5)+gradx(6)<0)*obj.uMin];

end

function [safe, uSafe, valuex] = isSafe2D(obj, other, safeV)
% function [safe, uSafe, valuex] = isSafe3D(obj, other, safeV)
%
% Safety check in the case where two 3D reachable sets are being combined
% into a 6D reachable set
%
% Mo Chen, 2015-10-19

% Unpack reachable set data
tau = safeV.tau;
dataC = safeV.dataC;
g = safeV.g;

% States in 4D reachable set
xr = obj.x(1) - other.x(1);
vxr = obj.x(2) - other.x(2);
yr = obj.x(3) - other.x(3);
vyr = obj.x(4) - other.x(4);
x = [xr vxr yr vyr];

% If the state is more than a grid point away from the computation domain,
% then the relative system is safe
if any(x' <= [g.min+g.dx; g.min+g.dx])
  safe = 1;
  uSafe = [0; 0];
  valueCx = max(dataC(:));
  valuex = valueCx;
  return
end

if any(x' >= [g.max-g.dx; g.max-g.dx])
  safe = 1;
  uSafe = [0; 0];
  valueCx = max(dataC(:));
  valuex = valueCx;
  return
end

% Check safety with respect to each dimension, just in case we are safe
% in both dimensions separately already
dataC_cons_x = min(dataC,[],3);
dataC_cons_y = min(dataC,[],3);

x_value = eval_u(g, dataC_cons_x, x(1:2));
y_value = eval_u(g, dataC_cons_y, x(3:4));

if max(x_value,y_value)>0
  safe = 1;
  uSafe = [0; 0];
  valueCx = max(dataC(:));
  valuex = valueCx;
  return
end

% Compute value at current state
TD_out_x = recon2x2D(tau, {g; g}, {dataC; dataC}, x, obj.tauInt);
valuex = TD_out_x.value;
gradx = TD_out_x.grad;

% Is the value safe?
if valuex <= 0
  safe = false;
else
  safe = true;
end

% Compute optimal safe controller
uSafe = [(gradx(2)>=0)*obj.uMax + (gradx(2)<0)*obj.uMin; ...
  (gradx(4)>=0)*obj.uMax + (gradx(4)<0)*obj.uMin];
end