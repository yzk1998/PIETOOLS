%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PIETOOLS_Hinf_estimator.m     PIETOOLS 2021b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script executes an H-infty gain analysis for a 4-PIE System defined
% by the 7 4-PI operator representation
% Top \dot x(t)=Aop  x(t) + B1op  w(t)
%          z(t)=C1op x(t) + D11op w(t)
%          y(t)=C2op x(t) + D21op w(t)
%
% NOTE: The resulting estimator has the form
% Top \dot \hat x(t)=Aop  \hat x(t) + (Pop)^{-1}Zop*(C2op \hat x(t)-y(t))
%
% NOTE: At present, there is an implicit assumption that TB1op=0;
%
% If any other parts of the PIE are present, these are ignored. Top, Aop,
% B1op, C1op, C2op, D11op, and D21op must be properly defined for the script to function.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following inputs must be defined externally:
%
% PIE - PIE data structure. Includes elements T,A,B1,C1,D11, C2, D21 - 4-PI operators, typically defined by the conversion script
%
% settings - a matlab structure with following fields are needed, if
% undefined default values are used
%
% sos_opts - options for the SOSSOLVER (e.g. sdp solver), typically defined by the solver script
%
% dd1,dd2,dd3,ddZ,opts,options1,options2,options - accuracy settings, typically defined by the settings script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEVELOPER LOGS:
% If you modify this code, document all changes carefully and include date
% authorship, and a brief description of modifications
%
% Initial coding MP,SS - 10_01_2020
%  MP - 5_30_2021; changed to new PIE data structure
% SS - 6/1/2021; changed to function, added settings input
% DJ - 06/02/2021; incorporate sosineq_on option, replacd gamma with gam to
%                   avoid conflict with MATLAB gamma function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [prog, Lop, gam, Pop, Zop] = PIETOOLS_Hinf_estimator(PIE, settings)

% get settings information
if nargin<2
    settings_PIETOOLS_light;
    settings.sos_opts.simplify = 1; % Use psimplify
    settings.eppos = 1e-4;      % Positivity of Lyapunov Function with respect to real-valued states
    settings.eppos2 = 1*1e-6;   % Positivity of Lyapunov Function with respect to spatially distributed states
    settings.epneg = 0*1e-5;    % Negativity of Derivative of Lyapunov Function in both ODE and PDE state -  >0 if exponential stability desired
end  

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
sosineq_on = settings.sosineq_on;
if sosineq_on
    opts = settings.opts;
else
    override2 = settings.override2;
    options2 = settings.options2;
    options3 = settings.options3;
    dd2 = settings.dd2;
    dd3 = settings.dd3;
end

fprintf('\n --- Executing Search for H_infty Optimal Estimator --- \n')

% Dumping relevant 4-PI operators from Data structure to the workspace -MP, 5/2021
Aop=PIE.A;
Top=PIE.T;
B1op=PIE.B1;    TB1op = PIE.Tw;
C1op=PIE.C1;
D11op=PIE.D11;
C2op=PIE.C2;
D21op=PIE.D21;

% Declare an SOS program and initialize domain and opvar spaces
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varlist = [Aop.var1; Aop.var2];  % retrieving the names of the independent pvars from Aop (typically s and th)
prog = sosprogram(varlist);      % Initialize the program structure
X=Aop.I;                         % retrieve the domain from Aop
nx1=Aop.dim(1,1);                % retrieve the number of ODE states from Aop
nx2=Aop.dim(2,1);                % retrieve the number of distributed states from Aop
nw=B1op.dim(1,2);                % retrieve the number of real-valued disturbances
nz=C1op.dim(1,1);                % retrieve the number of real-valued regulated outputs
ny=C2op.dim(1,1);                % retrieve the number of real-valued observed outputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The most common usage of this script is to find the minimum hinf gain bound
% In this case, we define the hinf norm variable which needs to be minimized
dpvar gam;
prog = sosdecvar(prog, gam); %this sets gamma as decision var
prog = sosineq(prog, gam); %this ensures gamma is lower bounded
prog = sossetobj(prog, gam); %this minimizes gamma, comment for feasibility test
%
% Alternatively, the above 3 commands may be commented and a specific gain
% test specified by defining a specific desired value of gamma. This
% results in a feasibility test instead of an optimization problem.
% gamma = 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1: declare the posopvar variable, Pop, which defines the storage 
% function candidate and the indefinite operator Zop, which is used to
% contruct the estimator gain
disp('- Declaring Positive Storage Operator variable and indefinite Observer operator variable using specified options...');

[prog, P1op] = poslpivar(prog, [nx1 ,nx2],X,dd1,options1);

if override1~=1
    [prog, P2op] = poslpivar(prog, [nx1 ,nx2],X,dd12,options12);
    Pop=P1op+P2op;
else
    Pop=P1op;
end

[prog,Zop] = lpivar(prog,[nx1 ny;nx2 0],X,ddZ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 2: Define the KYP matrix
%
% i.e. - Assemble the big operator
% Pheq = [ -gamma*I  -D11'       -(P*B1+Z*D21)'*T
%          -D11         -gamma*I            C1
%          -T'*(P*B1+Z*D21)      C1'       T'*(P*A+Z*C2)+(P*A+Z*C2)'*T]

disp('- Constructing the Negativity Constraint...');

Dop = [-gam*eye(nw)+TB1op'*(Pop*B1op+Zop*D21op)+(Pop*B1op+Zop*D21op)'*TB1op   -D11op'    -(Pop*B1op+Zop*D21op)'*Top-TB1op'*(Pop*Aop+Zop*C2op);
        -D11op                                                            -gam*eye(nz)            C1op;
        -Top'*(Pop*B1op+Zop*D21op)-(Pop*Aop+Zop*C2op)'*TB1op             C1op'              (Pop*Aop+Zop*C2op)'*Top+Top'*(Pop*Aop+Zop*C2op)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: Impose Negativity Constraint. There are two methods, depending on
% the options chosen
%
disp('- Enforcing the Negativity Constraint...');
if sosineq_on
    disp('  - Using lpi_ineq');
    prog = lpi_ineq(prog,-Dop,opts);
else
    disp('  - Using an Equality constraint...');
    [prog, De1op] = poslpivar(prog, [nw+nz+nx1, nx2],X,dd2,options2);
    
    if override2~=1
        [prog, De2op] = poslpivar(prog,[nw+nz+nx1, nx2],X, dd3,options3);
        Deop=De1op+De2op;
    else
        Deop=De1op;
    end
    prog = lpi_eq(prog,Deop+Dop); %Dop=-Deop
end


%solving the sos program
disp('- Solving the LPI using the specified SDP solver...');
prog = sossolve(prog,sos_opts); 

disp('The H-infty gain from disturbance to error in estimated state is upper bounded by:')
if ~isreal(gam)
    disp(double(sosgetsol(prog,gam))); % check the Hinf norm, if the solved successfully
else 
    disp(gam);
end

gam = double(sosgetsol(prog,gam));

P = getsol_lpivar(prog,Pop);
err = isequal(P.R.R1,P.R.R2);
if ~all(err(:))
    Lop = 'Inverse for opvar can only be calculated for opvar with R1=R2';
else
    Lop = getObserver(getsol_lpivar(prog, Pop), getsol_lpivar(prog, Zop));
end
end
