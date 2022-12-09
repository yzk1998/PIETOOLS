function out = uminus(objA)
if isa(objA,'equation')&&~objA.one_sided
    error('Incorrect equation format. Cannot negate equality A==B');
end
objA.rhs.operator = -objA.rhs.operator;
out = objA;
end