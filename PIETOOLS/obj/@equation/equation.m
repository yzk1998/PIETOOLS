classdef (InferiorClasses={?state})equation
    properties (Access = {?equation, ?sys})
        lhs = struct('operator',opvarND(),'statevec',state());
        rhs = struct('operator',opvarND(),'statevec',state());
    end
    methods
        function obj = terms(varargin)
            if nargin>2
                error('Terms object constructor takes only two inputs');
            end
            if nargin>1
                obj.rhs = varargin{2};
            end
            if nargin>0
                obj.lhs = varargin{1};
            end
        end
    end
end