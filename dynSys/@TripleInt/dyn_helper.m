function dx = dyn_helper(~, x, u, dims, dim)

switch dim
    case 1
        dx = x{dims==2};
    case 2
        dx = x{dims==3};
    case 3
        dx = u;
    otherwise
        error('Only dimension 1-3 are defined for dynamics of DoubleInt!')
end
end