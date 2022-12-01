function obj = removeequation(obj,eqnNumber)
obj.equations(eqnNumber) = [];
fprintf('%d equations were removed from the system\n', length(eqnNumber));
end