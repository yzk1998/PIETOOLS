function sumTerms = uminus(objA)
objC = state2terms(objA);
opvar T; T.R.R0 = -eye(objA.length);
sumTerms = terms(T,objC);
end