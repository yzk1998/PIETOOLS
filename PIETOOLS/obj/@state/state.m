classdef (InferiorClasses={?polynomial,?dpvar})state
    properties %(Access = {?equation, ?sys, ?state})
        type = 'finite';
        veclength = 1;
        var = pvar('t');
        diff_order = 0;
        maxdiff = "inf";
        dom = [];
    end
    properties (Hidden, SetAccess=protected)
        statename;
    end
    methods (Access = {?equation, ?sys, ?state})
        objterms = state2equation(obj,operator,var,val);
        [out, varargout] = combine(varargin);
    end
    methods
        function obj = state(varargin) %constructor
            if nargout==0
                for i=1:nargin
                    obj = state();
                    obj.statename = stateNameGenerator(1);
                    assignin('caller', varargin{i}, obj);
                end
            else
                if nargin==0
                    obj = state();
                end
                if nargin>=2
                    len = varargin{2};
                else
                    len = 1;
                end
                if nargin>4
                    error('Too many inputs to state function. Try "help state"');
                end
                if nargin>=1
                    if strcmp(varargin{1},'ode')||strcmp(varargin{1},'dde')||strcmp(varargin{1},'nds')||strcmp(varargin{1},'ddf')||strcmp(varargin{1},'finite')
                        obj.type = repmat({'finite'},len,1);
                        obj.var = repmat([pvar('t')],len,1);
                        obj.diff_order = repmat([0],len,1);
                        obj.dom = repmat([],len,1);
                        obj.maxdiff = repmat("inf",len,1);
                    elseif strcmp(varargin{1},'pde')||strcmp(varargin{1},'pie')||strcmp(varargin{1},'infinite')
                        obj.type = repmat({'infinite'},len,1);
                        obj.var = repmat([pvar('t'),pvar('s')],len,1);
                        obj.diff_order = repmat([0,0],len,1);
                        obj.dom = repmat([0,1],len,1);
                        obj.maxdiff = repmat(["inf","inf"],len,1);
                    else
                        msg = ['Unknown state type ',type,'. Allowed types: "ode,dde,nds,ddf,pde,pie"'];
                        error(msg);
                    end
                end
                if nargin>=2
                    if (numel(varargin{2})~=1)||(varargin{2}<=0)||mod(varargin{2},1)
                        error('Object length must be a positive integer');
                    end
                    obj.veclength = varargin{2};
                end
                if nargin>=3
                    if strcmp(obj.type,'finite')&&length(varargin{3})>1
                        error('Finite type state objects must be variables in single polynomial');
                    end
                    if size(varargin{3},1)~=1
                        error('var must be a row vector');
                    end
                    obj.var = repmat(varargin{3},len,1);
                end
                if nargin>=4 % internal use only, dont use this for constructing state objects
                    obj.statename = varargin{4};
                else
                    obj.statename = stateNameGenerator(len);
                end
            end
        end
    end
end