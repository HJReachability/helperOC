function dx = dynamics(obj, ~, x, u, d, ~)
% dx = dynamics(obj, t, x, u, d)
%     Dynamics of the robot arm

dx = cell(obj.nx,1);
dims = obj.dims;

returnVector = false;
if ~iscell(x)
  returnVector = true;
  x = num2cell(x);
  u = num2cell(u);
end

for i = 1:length(dims)
  dx{i} = dynamics_cell_helper(obj, x, u, d, dims, dims(i));
end

if returnVector
  dx = cell2mat(dx);
end
end

function dx = dynamics_cell_helper(obj, x, u, d, dims, dim)
    % Returns dx for each dimension of the state space

    flatSize = numel(x{1});
    switch dim
      case 1 % velocity of angle th1
        dx = x{dims==3};
      case 2 % velocity of angle th2
        dx = x{dims==4};
      case 3 % acceleration of angle th1
        % TODO This is inefficient to call twice for high DOF systems.
        [ddth1, ~] = arrayfun(@acceleration_helper, reshape(x{1}, [1, flatSize]), ...
            reshape(x{2}, [1, flatSize]), reshape(x{3}, [1, flatSize]), ...
            reshape(x{4}, [1, flatSize]), reshape(u{1}, [1, flatSize]), ...
            reshape(u{2}, [1, flatSize]));
        dx = reshape(ddth1, size(x{1}));
      case 4 % acceleration of angle th2
        [~, ddth2] = arrayfun(@acceleration_helper, reshape(x{1}, [1, flatSize]), ...
            reshape(x{2}, [1, flatSize]), reshape(x{3}, [1, flatSize]), ...
            reshape(x{4}, [1, flatSize]), reshape(u{1}, [1, flatSize]), ...
            reshape(u{2}, [1, flatSize]));
        dx = reshape(ddth2, size(x{1}));
      otherwise
        error('Only dimensions 1-4 are defined for dynamics of Arm4D!')
    end

    function [ddth1, ddth2] = acceleration_helper(th1, th2, dth1, dth2, u1, u2)
        % Computes acceleration given the current state and controls
        th = [th1; th2];
        dth = [dth1; dth2];
        M = obj.get_M(th);
        C = obj.get_C(th,dth);
        N = obj.get_N(th);
        uR = [u1; u2];
        %ddth = M\(uR + dH - C*dth - N);
        ddth = M\(uR - C*dth - N);
        ddth1 = ddth(1);
        ddth2 = ddth(2);
    end

end



