classdef (InferiorClasses={?state,?equation}) sys
    properties (SetAccess=protected)
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
    methods (Static)
        [type,params] = identifyParamsType(params);
        obj = initialize(params);
        obj = convert(varargin);
    end
    methods
        function obj = sys(varargin)
            if nargin>1
                msg = 'Too many inputs.';
                error(msg);
            end
            if nargin==1 && (isa(varargin{1},'string')||isa(varargin{1},'char'))
                obj.type =varargin{1};
                if strcmp(obj.type,'dde')
                    obj.params = tds_struct('dde');
                elseif strcmp(obj.type,'nds')
                    obj.params = tds_struct('nds');
                elseif strcmp(obj.type,'ddf')
                    obj.params = tds_struct('ddf');
                elseif strcmp(obj.type,'pie')
                    obj.params = pie_struct();
                end
            elseif isa(varargin{1},'struct')||isa(varargin{1},'pde_struct')...
                    ||isa(varargin{1},'tds_struct')||isa(varargin{1},'pie_struct')
                obj = sys.initialize(varargin{1});
            end
            fprintf('Initialized sys() object of type "%s"\n',obj.type);
        end
        % get methods
        function prop = get.params(obj)
            if isempty(obj.params)
                obj = getParams(obj);
                prop = obj.params;
            else
                prop = obj.params;
            end
        end
        function out = get.ControlledInputs(obj)
            if isempty(obj.ControlledInputs)
                out = zeros(length(obj.states),1);
            else
               out = obj.ControlledInputs;
            end
        end
        function out = get.ObservedOutputs(obj)
            if isempty(obj.ObservedOutputs)
                out = zeros(length(obj.states),1);
            else
                out = obj.ObservedOutputs;
            end
        end
        function out = get.dom(obj)
            out = obj.states.dom;
        end
        function prop = get.states(obj)
            prop = getStatesFromEquations(obj);
        end
    end
end