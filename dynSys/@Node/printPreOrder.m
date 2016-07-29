function printPreOrder(obj)
% printPreOrder(obj)
% Method of Node class
%
% Prints the subtree with the current node as the root, depth first,
% preorder traversal (root first, then children, recursively)

obj.printInfo;
children = obj.getChildren;
for i = 1:length(children)
  children{i}.printPreOrder;
end
end