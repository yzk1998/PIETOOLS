classdef (InferiorClasses={?polynomial,?dpvar})state
    properties (Access = {?equation, ?sys, ?state})
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
                    obj.statename = stateNameGenerator();
                    assignin('caller', varargin{i}, obj);
                end
            else
                if nargin>4
                    error('Too many inputs to state function. Try "help state"');
                end
                if nargin==4 % internal use only, dont use this for constructing state objects
                    obj.statename = varargin{4};
                else
                    obj.statename = stateNameGenerator();
                end
                if nargin==3
                    if strcmp(varargin{1},'finite')&&length(varargin{3})>1
                        error('Finite type state objects must be variables in single polynomial');
                    end
                    if size(varargin{3},1)~=1
                        error('var must be a row vector');
                    end
                    obj.var = varargin{3};
                end
                if nargin==2
                    if (numel(varargin{2})~=1) || (varargin{2}<=0)|| ~isinteger(varargin{2})
                        error('Object length must be a positive integer');
                    end
                    obj.veclength = varargin{2};
                end
                if nargin==1
                    obj.type = varargin{1};
                    if strcmp(varargin{1},'finite')
                        % default values, do nothing
                    elseif strcmp(varargin{1},'infinite')
                        obj.var = [pvar('t'),pvar('s')];
                        obj.diff_order = [0,0];
                        obj.dom = [0,1];
                    else
                        msg = ['Unknown state type ',type,'. Allowed types: "finite" or "infinite"'];
                        error(msg);
                    end
                end
            end
        end
    end
end