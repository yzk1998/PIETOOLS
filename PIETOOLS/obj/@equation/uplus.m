function out = uplus(objA)
if isa(objA,'equation')&&~objA.one_sided
    error('Incorrect equation format. Cannot perform uplus on equality A==B');
end
out = objA;
end