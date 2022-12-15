function out = mtimes(K,objA)
if isa(K,'equation')
    error('Left multiplication by state/equation object is not supported.');
end
if isa(objA,'equation')&&isa(K,'equation')
    error('Two equation type objects cannot be multiplied');
end
if numel(K)~=1 && (size(K,2)~=length(objA))
    error('Dimensions of multiplier and terms object do not match. Cannot be multiplied');
end

if isa(K,'opvarND')
    T = K;
else
opvarND T; 
if numel(K)==1
    T.N{0} = K*eye(length(objA));
else
    T.N{0} = K;
end
end
lhs = struct('operator',set(opvarND(),'dim.out',T.dim.out),'states',state());
rhs = struct('operator',T*objA.rhs.operator,'states',objA.rhs.states);
out = equation(lhs,rhs);
end