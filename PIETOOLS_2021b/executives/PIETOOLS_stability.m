%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PIETOOLS_stability.m     PIETOOLS 2022a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script executes a stability analysis for a 4-PIE System defined
% by the 2 4-PI operator representation
% Top \dot x(t)=Aop x(t)
%
% If any other parts of the PIE are present, these are ignored. Both Top
% and Aop must be properly defined for the script to function.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following inputs must be defined externally:
%
% PIE - PIE data structure. Includes T,A - 4-PI operators, typically defined by the conversion script
%
% settings - a matlab structure with following fields are needed, if
% undefined default values are used
% 
% eppos,eppos2,epneg % stricness terms typically defined by the solver script
%
% sos_opts - options for the SOSSOLVER (e.g. sdp solver), typically defined by the solver script
%
% dd1,dd2,dd3,opts,options1,options2,options - accuracy settings, typically defined by the settings script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEVELOPER LOGS:
% If you modify this code, document all changes carefully and include date
% authorship, and a brief description of modifications
%
% Initial coding MP,SS - 10_01_2020
%  MP - 5_30_2021; changed to new PIE data structure
% SS - 6/1/2021; changed to function, added settings input
% DJ - 06/02/2021; incorporate sosineq_on option
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [prog, P] = PIETOOLS_stability(PIE, settings)

if PIE.dim==2
    % Call the 2D version of the executive.
    if nargin==1
        [prog, P] = PIETOOLS_stability_2D(PIE);
    else
        [prog, P] = PIETOOLS_staibility_2D(PIE,settings);
    end
    return
end

% get settings information
if nargin<2
    settings_PIETOOLS_heavy;
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


fprintf('\n --- Executing Primal Stability Test --- \n')
% Declare an SOS program and initialize domain and opvar spaces
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varlist = [PIE.A.var1; PIE.A.var2];  % retrieving the names of the independent pvars from Aop (typically s and th)
prog = sosprogram(varlist);      % Initialize the program structure
X=PIE.A.I;                         % retrieve the domain from Aop
nx1=PIE.A.dim(1,1);                % retrieve the number of ODE states from Aop
nx2=PIE.A.dim(2,1);                % retrieve the number of distributed states from Aop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1: declare the posopvar variable, Pop, which defines the Lyapunov 
% function candidate
disp('- Parameterizing Positive Lyapunov Operator using specified options...');

[prog, P1op] = poslpivar(prog, [nx1 ,nx2],X,dd1,options1);

if override1~=1
    [prog, P2op] = poslpivar(prog, [nx1 ,nx2],X,dd12,options12);
    Pop=P1op+P2op;
else
    Pop=P1op;
end

% enforce strict positivity on the operator
Pop.P = Pop.P+eppos*eye(nx1);
Pop.R.R0 = Pop.R.R0+eppos2*eye(nx2);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 2: Define the Lyapunov Inequality
%
% i.e. - Assemble the big operator
% Pheq = [ A'*P*T+T'*P*A]

disp('- Constructing the Negativity Constraint...');

Dop = [PIE.T'*Pop*PIE.A+PIE.A'*Pop*PIE.T+epneg*PIE.T'*Pop*PIE.T]; 
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: Impose Negativity Constraint. There are two methods, depending on
% the options chosen
%
disp('- Enforcing the Negativity Constraint...');

if sosineq_on
    disp('  - Using lpi_ineq...');
    prog = lpi_ineq(prog,-Dop,opts);
else
    disp('  - Using an Equality constraint...');
    
    [prog, De1op] = poslpivar(prog, [nx1, nx2],X,dd2,options2);
    
    if override2~=1
        [prog, De2op] = poslpivar(prog,[nx1, nx2],X, dd3,options3);
        Deop=De1op+De2op;
    else
        Deop=De1op;
    end
    prog = lpi_eq(prog,Dop+Deop); %Dop=-Deop
end

disp('- Solving the LPI using the specified SDP solver...');
%solving the sos program
prog = sossolve(prog,sos_opts); 

% Conclusion:
P = getsol_lpivar(prog,Pop);

if isfield(settings.sos_opts,'solver')&&strcmp(settings.sos_opts.solver,'sdpt3')
    if exist('prog', 'var')
        if ~(prog.solinfo.info.pinf||prog.solinfo.info.dinf)
            disp('The System of equations was successfully solved.')
        elseif prog.solinfo.info.pinf || prog.solinfo.info.dinf
            disp('The System of equations was not solved.')
        else
            disp('Unable to definitively determine feasibility. Numerical errors dominating or at the limit of stability.')
        end
    end
elseif isfield(settings.sos_opts,'solver')&&strcmp(settings.sos_opts.solver,'sdpnalplus')
    if exist('prog', 'var')
        if ~(prog.solinfo.info.pinf||prog.solinfo.info.dinf)
            disp('The System of equations was successfully solved.')
        elseif ~(prog.solinfo.info.pinf||prog.solinfo.info.dinf) && prog.solinfo.info.numerr
            disp('The System of equations was successfully solved. However, Double-check the precision.')
        elseif prog.solinfo.info.pinf || prog.solinfo.info.dinf || prog.solinfo.info.numerr
            disp('The System of equations was not solved.')
        else
            disp('Unable to definitively determine feasibility. Numerical errors dominating or at the limit of stability.')
        end
    end
elseif exist('prog', 'var')
    if norm(prog.solinfo.info.feasratio-1)<=.3 && ~prog.solinfo.info.numerr
        disp('The System of equations was successfully solved.')
    elseif norm(prog.solinfo.info.feasratio-1)<=.3 && prog.solinfo.info.numerr
        disp('The System of equations was successfully solved. However, Double-check the precision.')
    elseif prog.solinfo.info.pinf || prog.solinfo.info.dinf || norm(prog.solinfo.info.feasratio+1)<=.1
        disp('The System of equations was not solved.')
    else
        disp('Unable to definitively determine feasibility. Numerical errors dominating or at the limit of stability.')
    end
else
    disp('System converted to PIE. No problem solved because executive file was not selected');
end
end
function prog = remove_dup(prog)
for i=1:length(prog.expr.At)
    At = prog.expr.At{i};
    b = prog.expr.b{i};
    C = [b';At];
    C = unique(C','rows','stable');
    C = C';
    prog.expr.b{i} = C(1,:)';
    prog.expr.At{i} = C(2:end,:);
    prog.expr.Z{i} = unique(prog.expr.Z{i},'rows');
end
end