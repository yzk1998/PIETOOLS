Atf = []; bf = [];
for i = 1:6
    Atf = [Atf, prog1_0.expr.At{i}];
    bf = [bf; prog1_0.expr.b{i}];
end;
RR = speye(1);
At = RR'*Atf;
c = sparse(size(At,1),1);
c(1:prog1_0.var.idx{end}-1) = c(1:prog1_0.var.idx{end}-1) + prog1_0.objective;       % 01/07/02
c = RR'*c;



K.s = [];
K.f = prog1_0.var.idx{1}-1;
RR = speye(K.f);

for i = 1:6
 sizeX = prog1_0.var.idx{i+1}-prog1_0.var.idx{i};
 startidx = prog1_0.var.idx{i};
 RR = spantiblkdiag(RR,speye(sizeX));
end;

sizeX = sqrt(prog1_0.var.idx{8}-prog1_0.var.idx{7});
startidx = prog1_0.var.idx{7};
RR = spblkdiag(RR,speye(sizeX^2));
K.s = [K.s sizeX];


m = min(size(At));
N = K.f + K.l + sum(K.q) + sum(K.r) + sum((K.s).^2);