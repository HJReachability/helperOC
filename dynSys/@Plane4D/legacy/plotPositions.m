    function plotPositions(planes, axs) 
      % function plotSafeV(obj, others, safeV, t)
      %
      % Plots positions of a list of planes
      %
      % Inputs: planes - list of planes whose positions must be plotted
      %
      % Mahesh Vashishtha, 2015-10-27        
      planes = checkVehiclesList(planes, 'plane');
      clf
      for i = 1:length(planes)
          x = planes{i}.x;
          q  = quiver(x(1), x(2), x(4)*cos(x(3)), x(4)*sin(x(3)));
          hold on;
      end
      set(q, 'AutoScale', 'off');       
      axis(axs);
    end      