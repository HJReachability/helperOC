function get_dataStr_test()

N = 5;

for i = 1:N
  dims = randi(6);
  disp(['dims = ' num2str(dims) ': ' get_dataStr(dims, 'i')])
end

for i = 1:N
  dims = randi(6);
  disp(['dims = ' num2str(dims) ': ' get_dataStr(dims, 'i-2', 'someVar')])
end
end