clc; clear;
pvar s t theta; % define independent variables
%% Define dependent variables and system variable
%   PDE:  x_{t} = a(s)*x_{ss}                       | a = s^3 - s^2 + 2     (unstable for lam > 4.66)            
%                 + b(s)*x_{s}                      | b = 3*s^2 - 2*s               Gahlawat 2017 [4]
%                 + c(s,lam)*x                      | c =-0.5*s^3 + 1.3*s^2 
%   BCs:  x(s=0) = 0,     x_{s}(s=1) = 0            |    - 1.5*s + 0.7 +lam
%                                                   | lam = 4.66
x = state('pde');
pde = sys(); lam = 4.66; a = s^3-s^2+2;b=3*s^2-2*s;c=-0.5*s^3+1.3*s^2-1.5*s+0.7+lam;
%% Define equations
eq_PDE = diff(x,t)==c*x+b*diff(x,s)+a*diff(x,s,2); % 	PDE: x_{t} = a(s)*x_{ss}+b(s)*x_{s}+c(s,lam)*x
eq_BC = [subs(x,s,0)==0;subs(diff(x,s),s,1)==0]; %  BCs: x(s=0) = 0,  x_{s}(s=1) = 0
%% addequations to pde system; set control inputs/observed inputs, if any
pde = addequation(pde,[eq_PDE;eq_BC]);
%% display pde to verify and convert to pie
display(pde);
pie = convert(pde,'pie');
display(pie);
