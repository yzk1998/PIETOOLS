function out = length(obj)
dim = obj.rhs.operator.dim;
out = sum(dim(:,1));
end