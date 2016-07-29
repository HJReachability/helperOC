classdef Node < handle
  % Node class: superclass of TFM, Highway, Platoon, and Vehicle
  % Used only for printing information
  %
  % The airspace can organized into a tree structure, where the TFM is the
  % root with Highway objects as children. Each Highway object has Platoon
  % objects as children, and each Platoon object has Vehicle objects as
  % children. All vehicles which are part of a platoon would be part of
  % this tree.
  
  % No explicit constructor; use the constructor of TFM, Highway, Platoon,
  % or Vehicle to instantiate a Node
end