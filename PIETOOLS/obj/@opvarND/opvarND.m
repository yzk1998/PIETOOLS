classdef (InferiorClasses={?polynomial,?dpvar}) opvarND
    properties
        dim = struct('in',[],'out',[]);
        N = {};
        dom = [];
        var = [];
    end
    methods
        function out = opvarND(varargin)
            for i=1:nargin
                if ischar(varargin{i})
                    if nargout==0
                        assignin('caller', varargin{i}, opvarND());
                    end
                else
                    error("Input must be strings");
                end
            end
        end
    end
end