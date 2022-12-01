classdef (InferiorClasses={?state,?equation}) sys
    properties
        type = 'pde';
        equations = equation();
        params = pde_struct();
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
            if isempty(obj.params.dom)
                obj = getParams(obj);
                prop = obj.params;
            else
                prop = obj.params;
            end
        end
        function out = get.ObservedOutputs(obj)
            if isempty(obj.ObservedOutputs)
                statelist = getStatesFromEquations(obj);
                if ~isempty(statelist)
                    out = zeros(length(statelist.veclength),1);
                else
                    out = [];
                end
            else
                out = obj.ObservedOutputs;
            end
        end
        function out = get.ControlledInputs(obj)
            if isempty(obj.ControlledInputs)
                statelist = getStatesFromEquations(obj);
                out = zeros(length(statelist.veclength),1);
            else
               out = obj.ControlledInputs;
            end
        end
        % set methods
        function obj = set.ObservedOutputs(obj,val)
            obj.ObservedOutputs = val;
        end
        function obj = set.ControlledInputs(obj,val)
            obj.ControlledInputs = val;
        end
    end
end