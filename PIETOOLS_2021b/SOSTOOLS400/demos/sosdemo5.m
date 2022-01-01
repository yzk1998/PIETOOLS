% SOSDEMO5 --- Upper bound for the structured singular value mu
% Section 3.5 of SOSTOOLS User's Manual
% 

clear; echo on;
pvar x1 x2 x3 x4 x5 x6 x7 x8;
vartable = [x1; x2; x3; x4; x5; x6; x7; x8];

% The matrix under consideration
alpha = 3 + sqrt(3);
beta = sqrt(3) - 1;
a = sqrt(2/alpha);
b = 1/sqrt(alpha);
c = b;
d = -sqrt(beta/alpha);
f = (1 + i)*sqrt(1/(alpha*beta));
U = [a 0; b b; c i*c; d f];
V = [0 a; b -b; c -i*c; -i*f -d];
M = U*V';

% Constructing A(x)'s
gam = 0.8724;

Z = monomials(vartable,1);
for i = 1:4
    H = M(i,:)'*M(i,:) - (gam^2)*sparse(i,i,1,4,4,1);
    H = [real(H) -imag(H); imag(H) real(H)];
    A{i} = (Z.')*H*Z;
end;

% =============================================
% Initialize the sum of squares program
prog = sosprogram(vartable);

% =============================================
% Define SOSP variables

% -- Q(x)'s -- : sums of squares
% Monomial vector: [x1; ... x8]
for i = 1:4
    [prog,Q{i}] = sossosvar(prog,Z);
end;

% -- r's -- : constant sum of squares
Z = monomials(vartable,0);
r = cell(4,4);
for i = 1:4
    for j = (i+1):4
        [prog,r{i,j}] = sossosvar(prog,Z,'wscoeff');
    end;
end;

% =============================================
% Next, define SOSP constraints

% Constraint : -sum(Qi(x)*Ai(x)) - sum(rij*Ai(x)*Aj(x)) + I(x) >= 0
expr = 0;
% Adding term
for i = 1:4
    expr = expr - A{i}*Q{i};
end;
for i = 1:4
    for j = (i+1):4
        expr = expr - A{i}*A{j}*r{i,j};
    end;
end;
% Constant term: I(x) = -(x1^4 + ... + x8^4)
I = -(x1^4+x2^4+x3^4+x4^4+x5^4+x6^4+x7^4+x8^4);
expr = expr + I;

prog = sosineq(prog,expr);

% =============================================
% And call solver
solver_opt.solver = 'sedumi';
prog = sossolve(prog,solver_opt);

% =============================================
% If program is feasible, 0.8724 is an upper bound for mu.
echo off