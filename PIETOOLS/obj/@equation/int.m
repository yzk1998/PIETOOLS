function out = int(objA, var, lim)
if isa(objA,'equation')&&~objA.one_sided
    error('Cannot perform integration on objects of form A==B');
end
opvarND intOP;

out = objA;
out.rhs.operator = intOP*out.rhs.operator;
end