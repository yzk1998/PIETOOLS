function obj = addequation(obj,eqn)
if isa(eqn,'state')
    eqn = state2equation(eqn);
elseif isa(eqn,'equation')
    % do nothing
else
    error('Unknown equation type. Cannot be added to system.');
end
obj.equation = [obj.equation; eqn];
fprintf('%d equations were added to sys() object\n',length(eqn));
end