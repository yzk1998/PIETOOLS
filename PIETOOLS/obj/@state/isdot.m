function logval = isdot(objA)
logval = zeros(length(objA),1);
for i=1:length(objA)
    logval(i) = (objA(i).diff_order(1)~=0);
end
end