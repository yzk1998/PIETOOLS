function strOut = stateNameGenerator(N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% internal method to generate unique ID for state class objects

persistent n

if isempty(n)
    n=0;
end

strOut = ((n+1):(n+N))';
n=n+N;
end