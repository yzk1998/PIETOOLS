function [out] = convert(obj,convertTo)
if strcmp(obj.type,'pie') %nothing to do
    out = obj;
    return;
end
if nargin==1
    convertTo='pie';
end
if strcmp(convertTo, 'pie')
    out = obj;
    out.type = 'pie';
    out.params = convert(obj.params);
elseif strcmp(convertTo,'ddf') && (strcmp(obj.type,'nds')||strcmp(obj.type,'dde'))
    out = obj;
    out.type = 'ddf';
    out.params = convert(obj.params,'ddf');
end
fprintf('Conversion to %s was successful\n', convertTo);
end