function logval = isdot(objA)
logval = []; 
for i=1:length(objA)
    logval = [logval; objA(i).diff_order(1)*ones(subsref(objA(i),s),1)];
end
logval = boolean(logval);
end