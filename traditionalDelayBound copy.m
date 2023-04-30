clear;clc;

stability=1;
stability_dual=1;
%%%%%%%%%%Subsystem 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NDS1.A0=[1.8 -0.3;0 2.5];
NDS1.B2=[1 0;0 1];
NDS1.Ai{1}=[-0.8 0;0.5 -0.2];
NDS1.Ei{2}=[-0.2 0.5;0.2 0.7];
NDS1.tau(1)= 0.4; 
NDS1.tau(2)= 0.3; 

NDS1=initialize_PIETOOLS_NDS(NDS1);
[DDF_max1, DDF1, PIE1] = convert_PIETOOLS_NDS(NDS1);

vars = PIE1.vars(:);
prog  = sosprogram(vars);
prog1  = sosprogram(vars);
prog2  = sosprogram(vars);
prog3  = sosprogram(vars);

dpvar gam;
prog = sosdecvar(prog,gam);
prog1 = sosdecvar(prog1,gam);
prog2 = sosdecvar(prog2,gam);
prog3 = sosdecvar(prog3,gam);


Kdim = PIE1.T.dim(:,1);
Kdom = PIE.dom;
Kdeg = {2,[1,1,2],[1,1,2]};
opts.sep = 0;
%[prog,K] = lpivar(prog,Kdim,Kdom,Kdeg);
[prog,K] = poslpivar(prog,Kdim,Kdom,Kdeg,opts);
[prog1,K] = poslpivar(prog1,Kdim,Kdom,Kdeg,opts);
eppos = 1e-3;
K.R.R0 = K.R.R0 + eppos*eye(size(K.R.R0));


[prog2,K2] = poslpivar(prog2,Kdim,Kdom,Kdeg,opts);
[prog3,K2] = poslpivar(prog3,Kdim,Kdom,Kdeg,opts);
eppos = 1e-3;
K2.R.R0 = K2.R.R0 + eppos*eye(size(K2.R.R0));


Hdim = PIE.T.dim(:,[2,1]);
Hdom = PIE.dom;
Hdeg = [4,0,0];
[prog,H] = lpivar(prog,Hdim,Hdom,Hdeg);
[prog1,H] = lpivar(prog1,Hdim,Hdom,Hdeg);


[prog2,H2] = lpivar(prog2,Hdim,Hdom,Hdeg);
[prog3,H2] = lpivar(prog3,Hdim,Hdom,Hdeg);


%coefficient
alpha1 = 1;
alpha2 = -1;

beta1 = 2;
beta2 = 2;

%operater
%Tbar = PIE.T + PIE.Tu*K
%Abar = PIE.A + PIE.B2*K

%closedLoopPIE(PIE_OL,Kval)

%Q = alpha*Tbar'*H*Tbar'+Tbar'*H*Abar'+Abar'*H*Tbar'


T = PIE.T;
A = PIE.A;
Bt2 = PIE.Tu;
B2 = PIE.B2;

Bt2.dim = H.dim;
B2.dim = H.dim;

%Tbar = T+Bt2*K
%Abar = A+B2*K

%Q = alpha*T'*H*T'+T'*H*A'+A'*H*T'
%Q = alpha*(T+Bt2*K)'*Hval*T'+(T+Bt2*K)'*Hval*A'+(A+B2*K)'*Hval*T'






%%%%%%%%%%%Subsystem 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NDS2.A0=[0.2 0;0 1.5];
NDS2.B2=[0 0;1 1];
NDS2.Ai{1}=[0.3 0;-0.2 -0.6];
NDS2.Ei{2}=[0.15 0;-0.15 0.8];
NDS2.tau(1)= 0.4; 
NDS2.tau(2)= 0.3; 

NDS2=initialize_PIETOOLS_NDS(NDS2);
[DDF_max2, DDF2, PIE2] = convert_PIETOOLS_NDS(NDS2);




%%%%%%%%%%%%%%%%%%%%   Controller 2    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M2 = alpha2*(T')*H2*T+(T')*H2*A+(A')*H2*T;
N2 = (-1*beta2)*(T')*H2*T+(T')*H2*A+(A')*H2*T;

zerOp = PIE.Tu;
zerOp.dim = M2.dim;

Q2 = [M2          zerOp;
    zerOp           N2];


prog2 = lpi_ineq(prog2,-Q2);

%prog = sossetobj(prog,gam)

opts.solver = 'sedumi';
opts.simplify = true;
prog_sol2 = sossolve(prog2,opts)

%gam_val = sosgetsol(prog_sol,gam)

Hval2 = getsol_lpivar(prog_sol2,H2)

%Q = alpha*(T+Bt2*K)'*Hval*T'+(T+Bt2*K)'*Hval*A'+(A+B2*K)'*Hval*T'

M2bar = alpha2*(T')*Hval2*T+(T')*Hval2*A+(A+B2*K2)'*Hval2*T;
N2bar = (-1*beta2)*(T')*Hval2*T+(T')*Hval2*A+(A+B2*K2)'*Hval2*T;

Qbar2 = [M2bar          zerOp;
    zerOp           N2bar];

prog3 = lpi_ineq(prog3,-Qbar2);

opts.solver = 'sedumi';
opts.simplify = true;
prog_sol3 = sossolve(prog3,opts)

%gam_val = sosgetsol(prog_sol,gam)

Kval2 = getsol_lpivar(prog_sol3,K2)




