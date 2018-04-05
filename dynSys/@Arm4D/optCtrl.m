function uOpt = optCtrl(obj, ~, x, deriv, uMode, ~)
    % uOpt = optCtrl(obj, ~, x, deriv, uMode, ~)
    % 
    % x has the structure:
    %   x(1) = [n x n x n x n] gridded values of theta1
    %   x(2) = [n x n x n x n] gridded values of theta2
    %   x(3) = [n x n x n x n] gridded values of dtheta1
    %   x(4) = [n x n x n x n] gridded values of dtheta2

    %% Input processing
    if nargin < 5
      uMode = 'min';
    end

    if ~iscell(deriv)
      deriv = num2cell(deriv);
    end

    % need to flatten all the cell arrays for arrayfun
    flat_size = numel(x{1});
    deriv_size = numel(deriv{1});
    % theta1, theta2 flattened arrays
    flat_th1 = reshape(x{1}, [1, flat_size]);
    flat_th2 = reshape(x{2}, [1, flat_size]);
    % partial derivatives flattened
    flat_p3 = reshape(deriv{3}, [1, deriv_size]);
    flat_p4 = reshape(deriv{4}, [1, deriv_size]);
    
    
    %% Optimal control
    % get the array of optimal controls for the array of possible states
    if deriv_size ~= flat_size
        % if the deriv size doesn't match the size of the state, then
        % assume derivatives are constant
        [u1out, u2out] = arrayfun(@get_opt_ctrl_fixedderiv, flat_th1, flat_th2);
    else
        [u1out, u2out] = arrayfun(@get_opt_ctrl, flat_th1, flat_th2, ...
            flat_p3, flat_p4);
    end
    
    uOpt{1} = reshape(u1out, size(x{1}));
    uOpt{2} = reshape(u2out, size(x{1}));

    function [u1, u2] = get_opt_ctrl(theta1, theta2, p3, p4)
        % p3 is partial derivative of V wrt dtheta1
        % p4 is partial derivative of V wrt dtheta2

        th = [theta1; theta2];
        M = obj.get_M(th);
        Minv = inv(M);

        coeff1 = p3*Minv(1,1)+p4*Minv(2,1);
        coeff2 = p3*Minv(1,2)+p4*Minv(2,2);

        if strcmp(uMode, 'max')
            if coeff1 > 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
            if coeff2 > 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
        elseif strcmp(uMode, 'min')
            if coeff1 < 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
            if coeff2 < 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
        else
          error('Unknown uMode!')
        end
        u1 = output(1);
        u2 = output(2);
    end

    function [u1, u2] = get_opt_ctrl_fixedderiv(theta1, theta2)
        % In the case that the derivatives are fixed values. 
        
        th = [theta1; theta2];
        M = obj.get_M(th);
        Minv = inv(M);

        coeff1 = flat_p3*Minv(1,1)+flat_p4*Minv(2,1);
        coeff2 = flat_p3*Minv(1,2)+flat_p4*Minv(2,2);

        if strcmp(uMode, 'max')
            if coeff1 > 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
            if coeff2 > 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
        elseif strcmp(uMode, 'min')
            if coeff1 < 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
            if coeff2 < 0
                output = obj.uMax;
            else
                output = obj.uMin;
            end
        else
          error('Unknown uMode!')
        end
        u1 = output(1);
        u2 = output(2);
    end

end

