classdef (InferiorClasses={?state})equation
    properties (Access = {?equation, ?sys})
        lhs = struct('operator',opvarND(),'states',state());
        rhs = struct('operator',opvarND(),'states',state());
    end
    properties (Hidden)
        one_sided=1;
    end
    methods
        function obj = equation(varargin)
            if nargin>2
                error('Terms object constructor takes only two inputs');
            end
            if nargin==1
                obj.rhs = varargin{1};
            end
            if nargin==2
                obj.lhs = varargin{2};
            end
        end
    end
end