function out = serializeStateVec(statevec)
out = zeros(length(statevec):4200);
for i=1:length(statevec)
    out(i,:) = getByteStreamFromArray(statevec(i));
end
end