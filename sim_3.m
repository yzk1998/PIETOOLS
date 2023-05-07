clear;clc;

settings = lpisettings('heavy');
dd1 = settings.dd1;
dd12 = settings.dd12;
sos_opts = settings.sos_opts;
options1 = settings.options1;
options12 = settings.options12;
override1 = settings.override1;
eppos = settings.eppos;
epneg = settings.epneg;
eppos2 = settings.eppos2;
ddZ = settings.ddZ;
sosineq_on = 1;


settings.opts.psatz = 1;
settings.opts.pure = 1;
opts = settings.opts;


stability=1;
stability_dual=1;
%%%%%%%%%%  Subsystem 1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NDS1.A0=[1.8 -0.3;0 2.5];
NDS1.B2=[1 0;0 1];
NDS1.Ai{1}=[-0.8 0;0.5 -0.2];
NDS1.Ei{2}=[-0.2 0.5;0.2 0.7];
NDS1.tau(1)= 4.0; 
NDS1.tau(2)= 3.0; 

NDS1=initialize_PIETOOLS_NDS(NDS1);
[DDF_max1, DDF1, PIE1] = convert_PIETOOLS_NDS(NDS1);


%%%%%%%%%%%  Subsystem 2  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NDS2.A0=[0.2 0;0 1.5];
NDS2.B2=[0 0;1 1];
NDS2.Ai{1}=[0.3 0;-0.2 -0.6];
NDS2.Ei{2}=[0.15 0;-0.15 0.8];
NDS2.tau(1)= 4.0; 
NDS2.tau(2)= 3.0; 

NDS2=initialize_PIETOOLS_NDS(NDS2);
[DDF_max2, DDF2, PIE2] = convert_PIETOOLS_NDS(NDS2);


Aop=PIE1.A;
Top=PIE1.T;
B1op=PIE1.B1;    TB1op = PIE1.Tw;
C1op=PIE1.C1;
D11op=PIE1.D11;
C2op=PIE1.C2;
D21op=PIE1.D21;

X=Aop.I;                         % retrieve the domain from Aop
nx1=Aop.dim(1,1);                % retrieve the number of ODE states from Aop
nx2=Aop.dim(2,1);                % retrieve the number of distributed states from Aop
nw=B1op.dim(1,2);                % retrieve the number of real-valued disturbances
nz=C1op.dim(1,1);                % retrieve the number of real-valued regulated outputs
ny=C2op.dim(1,1);                % retrieve the number of real-valued observed outputs


%%%%%%%%%%%%%%%%%%%%%%  Controller K1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vars = [PIE1.vars(:,1);PIE1.vars(:,2)];
prog1_0  = sosprogram(vars);
prog1_1  = sosprogram(vars);

dpvar gam1_0;
prog1_0 = sosdecvar(prog1_0,gam1_0);%Solve H1
prog1_0 = sosineq(prog1_0, gam1_0); 
prog1_0 = sossetobj(prog1_0,gam1_0);%Solve H1
dpvar gam1_1;
prog1_1 = sosdecvar(prog1_1,gam1_1);%Solve K1
prog1_1 = sosineq(prog1_1, gam1_1); 
prog1_1 = sossetobj(prog1_1,gam1_1);%Solve K1

%define H1
Hdim = PIE1.T.dim(:,[2,1]);
Hdom = PIE1.dom;
Hdeg = [4,0,0];
%[prog1_0,H1] = lpivar(prog1_0,Hdim,Hdom,Hdeg);
%[prog1_0,H1] = lpivar(prog1_1,Hdim,Hdom,Hdeg);
%[prog1,H] = lpivar(prog1,Hdim,Hdom,Hdeg);

Tbar = (PIE1.T)';
[prog1_0, H1] = poslpivar(prog1_0, PIE1.T.dim(:,1),X,dd1,options1);
%[prog1_0, H1_1] = lpivar(prog1_0, [Tbar.dim(:,2),PIE1.T.dim(:,1)],X,ddZ);


%define controller
K1 = [-4.3178 0.8389;
    -1.3983 -8.5722];

K2 = [-3.8051 0.8461;
    -1.0301 -8.2361];

opvar C1;
opvar C2;
C1.var1 = H1.var1;C1.var2 = H1.var2;
C2.var1 = H1.var1;C2.var2 = H1.var2;
C1.P = K1;C2.P = K2;
%C1.Q1 
%C1.Q2
%C1.R.R0
%1.R.R1
%C1.R.R2
C1.dim = PIE1.T.dim;C2.dim = PIE1.T.dim;
C1.I = PIE1.T.I;C2.I = PIE1.T.I;

%define zero Operater
opvar zerOp;
%zerOp.var1 = H1.var1;zerOp.var2 = H1.var2;
%zerOp.dim = PIE1.T.dim;
%zerOp.I = PIE1.T.I;
zerOp = 0*PIE1.T;
zerOp.P = 0*PIE1.T.P;
zerOp.Q1 = 0*PIE1.T.Q1;
zerOp.Q2 = 0*PIE1.T.Q2;
zerOp.R.R0 = 0*PIE1.T.R.R0;
zerOp.R.R1 = 0*PIE1.T.R.R1;
zerOp.R.R2 = 0*PIE1.T.R.R2;
%%%%%%%%%%%%%%%%%%%%%%%%%%% Thm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T1 = PIE1.T;
A1 = PIE1.A;
B2_1 = PIE1.B2;B2_1.dim = H1.dim;
%A1bar = A1+B2_1*K1
alpha1 = -1;

T2 = PIE2.T;
A2 = PIE2.A;
B2_2 = PIE2.B2;B2_2.dim = H1.dim;
%A1bar = A1+B2_1*K1
beta1 = 2;
%beta1 = 2;


M1 = alpha1*(T1')*H1*T1 + (T1')*H1*(A1+B2_1*C1) + ((A1+B2_1*C1)')*H1*T1;
N1 = (-1*beta1)*(T2')*H1*T2 + (T2')*H1*(A2+B2_2*C1) + ((A2+B2_2*C1)')*H1*T2;



%Merge Criterion
%step1:H1
Q1_1 = [M1          zerOp;
    zerOp           N1];

%prog1_0 = lpi_ineq(prog1_0,-Q1_1,opts);
prog1_0 = lpi_ineq(prog1_0,-Q1_1,opts);

opts.solver = 'sedumi';
opts.simplify = true;
prog_sol1_0 = sossolve(prog1_0,opts);

Hval1 = getsol_lpivar(prog_sol1_0,H1);


