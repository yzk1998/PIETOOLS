function obj = eq(objA,objB)
if isa(objA,'equation')&&~objA.one_sided
    error('Incorrect equation format. Cannot process equations of the form A==B==C');
end
if isa(objB,'equation')&&~objB.one_sided
    error('Incorrect equation format. Cannot process equations of the form A==B==C');
end
if isa(objA,'state')
    objA = state2equation(objA);
end
if isa(objB,'state')
    objB = state2equation(objB);
end
if ~isa(objA,'equation')&&(objA==0)
    rhs = objB.rhs;
    lhs.operator = set(opvarND(),'dim.out',rhs.operator.dim.out); 
    lhs.states = []; 
    obj = equation(rhs,lhs);
elseif ~isa(objB,'equation')&&(objB==0)
    objA = -objA;
    rhs = objA.rhs;
    lhs.operator = set(opvarND(),'dim.out',rhs.operator.dim.out); 
    lhs.states = []; 
    obj = equation(rhs,lhs);
elseif isa(objA,'equation')&&isa(objB,'equation')
    obj = objA-objB;
else
    error('Invalid equation format. Equations must be of the form "expr==0" or "exprA==exprB"');
end
obj.one_sided = 0;
end