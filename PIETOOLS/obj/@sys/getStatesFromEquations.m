function out = getStatesFromEquations(obj)
equations = obj.equations;
eqnNum = length(equations);
if eqnNum==0
    out = [];
else
    out = [];
    for i=1:eqnNum
        tempterms = equations(i);
        out = combine(out,tempterms.statevec);
    end
end
end
