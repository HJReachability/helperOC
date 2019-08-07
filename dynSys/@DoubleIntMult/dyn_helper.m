function dx = dyn_helper(obj, x, u, d, dims, dim)

switch dim
  case 1
    dx = x{dims==2}+d;
  case 2
    dx = (obj.k).*u;
  otherwise
    error('Only dimension 1-2 are defined for dynamics of DoubleInt!')
end
end