function out = plus(objA,objB)
if isa(objA,'equation')&&~objA.one_sided
    error('Incorrect format. Cannot add A==B to C');
end
if isa(objB,'equation')&&~objB.one_sided
    error('Incorrect format. Cannot add A to B==C');
end
if length(objA)~=length(objB)
    error('Objects of unequal length cannot be added');
end
if isa(objA,'state')
    objA = state2equation(objA);
elseif ~isa(objA,'equation')
    error('Only state/equation type objects can be added');
end
if isa(objB,'state')
    objB = state2equation(objB);
elseif ~isa(objB,'equation')
    error('Only state/equation type objects can be added');
end


[tmpstatevec,PA,PB] = combine(objA.rhs.states, objB.rhs.states);
tmpoperator = [objA.rhs.operator objB.rhs.operator]*[PA; PB];

lhs = struct('operator',set(opvarND(),'dim.out',tmpoperator.dim.out),'states',[]);
rhs = struct('operator',tmpoperator,'states',tmpstatevec);
out = equation(lhs,rhs);
end