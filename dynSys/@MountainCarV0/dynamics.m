function dx = dynamics(obj, t, x, u, d)

    gravity = obj.gravity;
    force = obj.force;
    
%         velocity += (action - 1) * self.force + math.cos(3 * position) * (-self.gravity)
%         velocity = np.clip(velocity, -self.max_speed, self.max_speed)
%         position += velocity
%         position = np.clip(position, self.min_position, self.max_position)
if iscell(x)
  dx = cell(obj.nx, 1);
  
  position = x{1};
  velocity = x{2};
  
  dx{1} = velocity;
  dx{2} = (u - 1) * force + cos(3 * position) * (-gravity);
else
  dx = zeros(obj.nx, 1);

  position = x(1);
  velocity = x(2);
   
  dx(1) = velocity;
  % u ~ { 0, 1, 2 }
  dx(2) = (u - 1) * force + cos(3 * position) * (-gravity);
end


end