function obj = eq(objA,objB)
if isa(objA,'state')
    objA = state2equation(objA);
end
if isa(objB,'state')
    objB = state2equation(objB);
end
if ~isa(objA,'equation')&&(objA==0)
    lhs.operator = ; lhs.states =; rhs = objB.rhs;
    obj = equation(lhs,rhs);
elseif ~isa(objB,'equation')&&(objB==0)
    obj = objA;
elseif isa(objA,'equation')&&isa(objB,'equation')
    obj = objA-objB;
else
    error('Invalid equation format. Equations must be of the form "expr==0" or "exprA==exprB"');
end
end