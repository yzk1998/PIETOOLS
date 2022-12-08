function logval = isequal(objA,objB)
logval = 1;
if ~isa(objA,'equation')||~isa(objB,'equation')
    logval = 0;
    return
end
if (objA.rhs.operator~=objB.rhs.operator)
    logval=0;
    return
end
if (objA.rhs.states~=objB.rhs.states)
    logval=0;
    return
end
if (objA.lhs.operator~=objB.lhs.operator)
    logval=0;
    return
end
if (objA.lhs.states~=objB.lhs.states)
    logval=0;
    return
end
end