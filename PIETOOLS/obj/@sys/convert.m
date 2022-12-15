function [out] = convert(varargin)
if nargin==1
    params = varargin{1};
    convertTo='pie';
elseif nargin==2
    params = varargin{1};
    convertTo = varargin{2};
end
if ~isa(params,'sys')
    obj = sys.initialize(params);
else
    obj = params;
end
if strcmp(obj.type,'pie') %nothing to do
    out = obj;
    return;
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