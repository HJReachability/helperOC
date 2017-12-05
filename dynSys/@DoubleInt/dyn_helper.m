function dx = dyn_helper(obj, x, u, dims, dim)

switch dim
  case 1
    dx = x{dims==2};
  case 2
    dx = u;
  otherwise
    error('Only dimension 1-2 are defined for dynamics of DoubleInt!')
end
end