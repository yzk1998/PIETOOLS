function out = getParams(obj)
if strcmp(obj.type,'pde')
    obj.params = getPDEparams(obj);
    out = obj;
elseif strcmp(obj.type,'dde')
    obj.params = getDDEparams(obj);
    out = obj;
elseif strcmp(obj.type,'ddf')
    obj.params = getDDFparams(obj);
    out = obj;
elseif strcmp(obj.type,'nds')
    obj.params = getNDSparams(obj);
    out = obj;
elseif strcmp(obj.type,'pie')
    % do nothing. Return the params as is
    out = obj.params;
else
    msg = ['Cannot parse the system. Unknown sys object of type ',obj.type];
    error(msg);
end
end
