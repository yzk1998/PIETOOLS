clear;clc;

stability=1
stability_dual=1

NDS.A0=[-.9 .2;.1 -.9];
NDS.Ai{1}=[-1.1 -.2;-.1 -1.1];
NDS.Ei{1}=[-.2 0;.2 -.1];
NDS.tau(1)= 2.2; 

NDS=initialize_PIETOOLS_NDS(NDS);
[DDF_max, DDF, PIE] = convert_PIETOOLS_NDS(NDS);



%open loop stability test
settings = lpisettings('light');
[prog, P] = lpisolve(PIE,settings,'stability');

%sett = lpisettings('heavy');
%[prog, K, gamma, P, Z] = PIETOOLS_Hinf_control(PIE,sett);

%% constructing closed loop system
%PIE = closedLoopPIE(PIE,K);
%ndiff = [0, PIE.T.dim(2,1)];


%% Setting PIESIM simulation parameters
syms st;
uinput.w = sin(5*st)*exp(-st); 
uinput.u = 0;
uinput.ic.ODE = [1;0];
uinput.ic.PDE = [0,0];  

opts.plot='no';
opts.N=8;
opts.tf=1;
opts.intScheme=1;
opts.Norder = 2;
opts.dt=1e-3;

ndiff = [0,2,0];


%% Simulating and plotting open loop system
[solution_ol,grids] = PIESIM(NDS,opts,uinput,ndiff);
%%
plot(solution_ol.timedep.dtime,solution_ol.timedep.ode,'--o','MarkerIndices',1:50:length(solution_ol.timedep.dtime));
ax = gca;
set(ax,'XTick',solution_ol.timedep.dtime(1:150:end));
lgd1 = legend('$x_1$','$x_2$','Interpreter','latex'); lgd1.FontSize = 10.5; 
lgd1.Location = 'northeast';
title('Time evolution of the Delay system states, x, without state feedback control');
ylabel('$x_1(t), ~~~x_2(t)$','Interpreter','latex','FontSize',15);
xlabel('t','FontSize',15,'Interpreter','latex');

tval = solution_ol.timedep.dtime;
phi1 = reshape(solution_ol.timedep.pde(:,1,:),opts.N+1,[]);
phi2 = reshape(solution_ol.timedep.pde(:,2,:),opts.N+1,[]);
%zval =solution_ol.timedep.regulated;
wval=subs(uinput.w,st,tval);

figure(1);
surf(tval,grids.phys,phi2,'FaceAlpha',0.75,'Linestyle','--','FaceColor','interp','MeshStyle','row');
h=colorbar ;
colormap jet
box on
ylabel(h,'$|\dot{\mathbf{x}}(t,s)|$','interpreter', 'latex','FontSize',15)
set(gcf, 'Color', 'w');
xlabel('$t$','FontSize',15,'Interpreter','latex');    ylabel('$s$','FontSize',15,'Interpreter','latex');
zlabel('$\dot{\mathbf{x}}(t,s)$','FontSize',15,'Interpreter','latex');
title('Open loop zero-state response with $w(t)=sin(5t)e^{-t}$','Interpreter','latex','FontSize',15);
















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

