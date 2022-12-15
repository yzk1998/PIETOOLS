
% % This script illustrates how PIETOOLS can be used to test stability of
% % a simple reaction-diffusion PDE:
% % 
% % \dot{x}(t,s) = d^2/ds^2 x(t,s) + lam * x(t,s)              s in [0,1]
% %       x(t,0) = x(t,1) = 0
% %
% % A description of this code is given in PIETOOLS_How_to_get_started.pdf.

%%
clc; clear;
echo on
%%%%%%%%%%%%%%%%%% Start Code Snippet %%%%%%%%%%%%%%%%%%

% % % Declare the PDE
% Declare state variable x.
x = state('pde'); 
% Declare spatial and temporal variables s and t.
pvar s t; 
% Declare the value of reaction parameter lam.
lam = 9;
% Initialize the PDE system structure.
pde = sys();
% Declare the dynamics: d/dt x(t,s) = d^2/ds^2 x(t,s) + lam * x(t,s);
dynamics = (diff(x,t) == diff(x,s,2) + lam*x);
% Declare the boundary conditions: x(t,s=0) = x(t,s=1) = 0;
BC = [subs(x,s,0)==0; subs(x,s,1)==0];
% Add the dynamics and BCs to the PDE system structure.
pde = addequation(pde,[dynamics;BC]);


% % % Convert the PDE to a PIE
pie = convert(pde,'pie');


% % % Run LPI stability test for PIE, using 'veryheavy' settings
[prog, Pop] = lpisolve(pie.params, 'veryheavy', 'stability');

%%%%%%%%%%%%%%%%%% End Code Snippet %%%%%%%%%%%%%%%%%%
echo off