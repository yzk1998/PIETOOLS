classdef (InferiorClasses={?state,?equation}) sys
    properties
        type = 'pde';
        equations = equation();
        params = [];
        ControlledInputs = [];
        ObservedOutputs = [];
    end
    properties (Dependent)
        states;
        dom;
    end
    methods
        function obj = sys(varargin)
            if nargin>1
                msg = 'Too many inputs.';
                error(msg);
            end
            if nargin==1
                obj.type =varargin{1};
            end
            fprintf('Initialized sys() object of type "%s"\n',obj.type);
        end
        % get methods
        function prop = get.states(obj)
            prop = getStatesFromEquations(obj);
        end
        function prop = get.params(obj)
            if isempty(obj.params)
                obj = getParams(obj);
                prop = obj.params;
            else
                prop = obj.params;
            end
        end
        function out = get.ObservedOutputs(obj)
            if isempty(obj.ObservedOutputs)
                out = zeros(length(obj.states),1);
            else
                out = obj.ObservedOutputs;
            end
        end
        function out = get.ControlledInputs(obj)
            if isempty(obj.ControlledInputs)
                out = zeros(length(obj.states),1);
            else
               out = obj.ControlledInputs;
            end
        end
    end
end