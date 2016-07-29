classdef DynSys < Node
  % Dynamical Systems class
  %   Subclasses: quadrotor, Dubins vehicle (under construction)
  
  properties
    ID          % ID number (global, unique)

    nx          % Number of state dimensions
    nu          % Number of control inputs
    nd          % Number of disturbance dimensions
    
    x           % State
    u           % Recent control signal
    
    xhist       % History of state
    uhist       % History of control
    
    pdim        % position dimensions
    vdim        % velocity dimensions
    hdim        % heading dimensions
    
    % Mode
    %   'Free'
    %   'Follower'
    %   'Leader'
    %   'Faulty'
    q = 'Free'

    % Status (when requesting control from TFM)
    %   'idle'
    %   'busy'
    tfm_status = 'idle'
    
    %% Platoon-related properties
    p           % Pointer to platoon
    idx         % Vehicle index in platoon (determines phantom position)
    FQ          % Pointer to quadrotor in front (self if leader)
    BQ          % Pointer to quadrotor behind (self if tail)
    
    pJoin       % platoon that vehicle is trying to join
    
    %% Figure handles
    hpxpy           % Position
    hpxpyhist       % Position history
    hvxvy           % Velocity
    hvxvyhist       % Velocity history
    
    % Position velocity (so far only used in DoubleInt)
    hpv = cell(2,1);
    hpvhist = cell(2,1);
    
    h_abs_target_V     % for getting to an absolute target
    h_rel_target_V     % for getting to a relative target
    h_safe_V           % Safety sets
    h_safe_V_list      % List of vehicles for which safety set is being plotted
    
    % Data (any data that you may want to store for convenience)
    data
  end % end properties

  % No constructor in vehicle class. Use constructors in the subclasses
  
end % end class