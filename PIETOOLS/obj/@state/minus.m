function out= minus(objA,objB)
if ~isa(objA,'state')||~isa(objB,'state')
    error('Only state type objects can be added together');
end
if length(objA)~=length(objB)
    error('States of unequal length cannot be added');
end

[objC,permMatsA,permMatsB] = combine(objA,objB); % objA = permMats{1}*objC and objB = permMats{2}*objC

opvarND T; 
T.N{0} = permMatsA-permMatsB;
rhs = struct('operator',T,'states',objC);
lhs = struct('operator',set(opvarND(),'dim.out',T.dim.out),'states',[]);
out = equation(lhs,rhs);
end