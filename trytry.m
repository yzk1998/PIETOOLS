clear;clc;

stability=1;
stability_dual=1;

NDS.A0=[-2 1;0 -1];
NDS.Ai{1}=[0 .3;-.3 0];
NDS.Ai{2}=[.1 -.05;.05 .1];
NDS.Ei{1}=[0 -.1;-.1 0];
NDS.Ei{2}=[.05 0;0 .05];
NDS.tau(1)= 2.262; 
NDS.tau(2)= .5;

NDS=initialize_PIETOOLS_NDS(NDS);
[DDF_max, DDF, PIE] = convert_PIETOOLS_NDS(NDS);

sett = lpisettings('heavy');
[prog, K, gamma, P, Z] = PIETOOLS_Hinf_control(PIE,sett);

%% constructing closed loop system
PIE = closedLoopPIE(PIE,K);
ndiff = [0, PIE.T.dim(2,1)];

%% Setting PIESIM simulation parameters
syms st;
uinput.w = -4*st-4;
uinput.u = 0;
uinput.ic.ODE = [1;0];
opts.plot='no';
opts.N=8;
opts.tf=1;
opts.intScheme=1;
opts.Norder = 2;
opts.dt=1e-3;

%% Simulating and plotting closed loop system
opts.tf=10;
uinput.ic.PDE = [0;0]; uinput.ic.ODE = [0,0];
solution_cl=PIESIM(PIE,opts,uinput,ndiff);

plot(solution_cl.timedep.dtime,solution_cl.timedep.ode,'--o','MarkerIndices',1:50:length(solution_cl.timedep.dtime));
ax = gca;
set(ax,'XTick',solution_cl.timedep.dtime(1:150:end));
lgd1 = legend('$x_1$','$x_2$','Interpreter','latex'); lgd1.FontSize = 10.5; 
lgd1.Location = 'northeast';
title('Time evolution of the Delay system states, x, with state feedback control');
ylabel('$x_1(t), ~~~x_2(t)$','Interpreter','latex','FontSize',15);
xlabel('t','FontSize',15,'Interpreter','latex');






