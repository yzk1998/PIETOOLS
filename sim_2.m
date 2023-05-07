clear;clc;

stability=1;
stability_dual=1;
%%%%%%%%%%  Subsystem 1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NDS1.A0=[1.8 -0.3;0 2.5];
NDS1.B2=[1 0;0 1];
NDS1.Ai{1}=[-0.8 0;0.5 -0.2];
NDS1.Ei{2}=[-0.2 0.5;0.2 0.7];
NDS1.tau(1)= 0.4; 
NDS1.tau(2)= 0.3; 

NDS1=initialize_PIETOOLS_NDS(NDS1);
[DDF_max1, DDF1, PIE1] = convert_PIETOOLS_NDS(NDS1);

%%%%%%%%%%%  Subsystem 2  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NDS2.A0=[0.2 0;0 1.5];
NDS2.B2=[0 0;1 1];
NDS2.Ai{1}=[0.3 0;-0.2 -0.6];
NDS2.Ei{2}=[0.15 0;-0.15 0.8];
NDS2.tau(1)= 0.4; 
NDS2.tau(2)= 0.3; 

NDS2=initialize_PIETOOLS_NDS(NDS2);
[DDF_max2, DDF2, PIE2] = convert_PIETOOLS_NDS(NDS2);


%%%%%%%%%%%%%%%%%%%%%%  Controller K1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vars = PIE1.vars(:);
prog1_0  = sosprogram(vars);
prog1_1  = sosprogram(vars);

dpvar gam1_0;
prog1_0 = sosdecvar(prog1_0,gam1_0);%Solve H1
dpvar gam1_1;
prog1_1 = sosdecvar(prog1_1,gam1_1);%Solve K1

%define H1
Hdim = PIE1.T.dim(:,[2,1]);
Hdom = PIE1.dom;
Hdeg = [4,0,0];
[prog1_0,H1] = lpivar(prog1_0,Hdim,Hdom,Hdeg);
[prog1_0,H1] = lpivar(prog1_1,Hdim,Hdom,Hdeg);
%[prog1,H] = lpivar(prog1,Hdim,Hdom,Hdeg);

%define K1
Kdim = PIE1.T.dim(:,1);
Kdom = PIE1.dom;
Kdeg = {2,[1,1,2],[1,1,2]};
opts.sep = 0;
%[prog,K] = lpivar(prog,Kdim,Kdom,Kdeg);
%[prog1_0,K] = poslpivar(prog,Kdim,Kdom,Kdeg,opts);
[prog1_1,K1] = poslpivar(prog1_0,Kdim,Kdom,Kdeg,opts);
[prog1_1,K1] = poslpivar(prog1_1,Kdim,Kdom,Kdeg,opts);
eppos = 1e-3;
K1.R.R0 = K1.R.R0 + eppos*eye(size(K1.R.R0));

T1 = PIE1.T;
A1 = PIE1.A;
B2_1 = PIE1.B2;B2_1.dim = H1.dim;
%A1bar = A1+B2_1*K1
alpha1 = 1;

T2 = PIE2.T;
A2 = PIE2.A;
B2_2 = PIE2.B2;
%A1bar = A1+B2_1*K1
beta1 = 2;

%Criterion For Contoller 1
M1 = alpha1*(T1')*H1*T1 + (T1')*H1*A1 + (A1')*H1*T1;
N1 = (-1*beta1)*(T2')*H1*T2 + (T2')*H1*A2 + (A2')*H1*T2;

%zero Operater
zerOp = PIE1.Tu;
zerOp.dim = M1.dim;

%Merge Criterion
%step1:H1
Q1_1 = [M1          zerOp;
    zerOp           N1];

prog1_0 = lpi_ineq(prog1_0,-Q1_1);

opts.solver = 'sedumi';
opts.simplify = false;
prog_sol1_0 = sossolve(prog1_0,opts);

Hval1 = getsol_lpivar(prog_sol1_0,H1);

%step2:K1
M1bar = alpha1*(T1')*Hval1*T1 + (T1')*Hval1*(A1+B2_1*K1) + ((A1+B2_1*K1)')*Hval1*T1;
N1bar = (-1*beta1)*(T2')*Hval1*T2 + (T2')*Hval1*(A2+B2_2*K1) + ((A2+B2_2*K1)')*Hval1*T2;

Q1_2 = [M1bar          zerOp;
    zerOp           N1bar];

prog1_1 = lpi_ineq(prog1_1,-Q1_2);

opts.solver = 'sedumi';
opts.simplify = false;
prog_sol1_1 = sossolve(prog1_1,opts);

Kval1 = getsol_lpivar(prog_sol1_1,K1);



