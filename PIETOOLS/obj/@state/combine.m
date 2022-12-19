function [out, varargout] = combine(varargin)
out = varargin{1};
for i=2:nargin
    tmp = varargin{i};
    for j=1:length(tmp)
        s.type = '()'; s.subs = {j};
        temp = subsref(tmp,s); 
        if ~ismember(temp,out)
            out = [out; temp];
        end
    end
end

varargout = cell(1,nargin);

for i=1:nargin
    varargout{i} = findPermutation(out,varargin{i});
end
end
function P = findPermutation(A,B) % returns P, such that B = P*A
s.type = '.'; s.subs = 'veclength';
P = zeros(subsref(B,s),subsref(A,s));
[~,idx] = ismember(B,A);
P(sub2ind(size(P),1:subsref(B,s),idx)) = 1;
end