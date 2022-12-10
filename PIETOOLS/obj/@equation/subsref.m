function out = subsref(obj,s)
switch s(1).type
    case '.'
        out = builtin('subsref',obj,s);
    case '()'
        lhs.states = obj.lhs.states;
        rhs.states = obj.rhs.states;
        lhs.operator = obj.lhs.operator(s(1).subs{1},:);
        rhs.operator = obj.rhs.operator(s(1).subs{1},:);
        out = equation(lhs,rhs);
    otherwise
        error('Not a valid indexing expression');
end
end