function out = length(obj)
s.type = '.'; s.subs = 'veclength';
out = sum(subsref(obj,s));
end