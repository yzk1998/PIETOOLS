function out = eq(objA,objB)
if ~isa(objA,'state')&&(objA==0)
    out = state2equation(-objB);
elseif ~isa(objB,'state')&&(objB==0)
    out = state2equation(objA);
elseif isa(objA,'state')&&isa(objB,'state')
    out = objA-objB;
else
    error('Invalid equation format. Equations must be of the form "expr==0" or "exprA==exprB"');
end
end