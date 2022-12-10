function obj = vertcat(varargin)
if nargin==1
    obj = varargin{1};
else
    objA = varargin{1};
    objB = varargin{2};
    if isa(objA,'state')
        objA = state2equation(objA);
    end
    if isa(objB,'state')
        objB = state2equation(objB);
    end

    lhs = struct('operator',blkdiag(objA.lhs.operator,objB.lhs.operator),...
        'states',vertcat(objA.lhs.states, objB.lhs.states));
    rhs = struct('operator',blkdiag(objA.rhs.operator,objB.rhs.operator),...
        'states',vertcat(objA.rhs.states, objB.rhs.states));
    
    obj = equation(lhs,rhs);
    if nargin>2
        obj = vertcat(obj,varargin{3:end});
    end
end
end