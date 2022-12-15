function obj = initialize(params)
if isa(params,'struct')||isa(params,'tds_struct')
    [type,params] = sys.identifyParamsType(params);
    obj = sys(type);
    obj.params = params;
elseif isa(params,'pde_struct')
    obj = sys('pde');
    obj.params = pde_struct.initialize(params);
elseif isa(params,'pie_struct')
    obj = sys('pie');
    obj.params = pie_struct.initialize(params);
else
    error('Unknown system type.');
end
end