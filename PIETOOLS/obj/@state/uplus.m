function obj_out = uplus(obj_in)
isdot_A = isdot(obj_in); isout_A=isout(obj_in); 
if any((isdot_A|isout_A))
    error("Unitary plus involving vectors with outputs or time-derivative of state is not allowed");
end
s.type = '.'; s.subs = 'veclength';
opvar T; T.R.R0 = eye(sum(subsref(obj_in,s)));
obj_out = equation(T,obj_in);
end