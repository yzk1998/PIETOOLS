xclc; clear; 
% Scalable Global Stability Analysis Test Code


% pvar p1 p2
% g=(1-p1^2-p2^2); % norm{p1,p2} \le 1
% % g1=p1*(1-p2);
% % g2=p1*(1-p1)*p2*(1-p2); % p1,p2 \in [0,1]

% Example from Hajer Bouzaouache and Naceur Benhadj Braiek, 2007
% See also (Benhadj et al., 1995; Rotella and Dauphin,1988;
%  Bouzaouache, et al.,2003)

% for i=1:6
% c{i}=['p',int2str(i)];
% temp=pvar(c{i});
% xvartable=[xvartable temp];
% end
% 
% F1=[-7.3 .1 -.3 .2 -.3 .2;
%     .3 -7.4 .1 -.4 .1 -.4;
%     -.3 .2 -8 .2 -.3 .2;
%     .1 -.8 -.5 -7 .1 -.4;
%     -.3 .2 -.3 .2 -7.7 .2;
%     .1 -.4 .1 -.4 .2 -7];
% F2=zeros(6,36);
% F2(1,8)=-.5;
% F2(2,8)=-1.5;
% F2(3,22)=-.1;
% F2(4,22)=-9;
% F2(5,36)=-.5;
% F2(6,36)=-1.5;
% 
% F3=zeros(6,216);
% F3(1,216)=-.1;
% F3(2,130)=-.1;
% F3(2,216)=-.1;
% F3(3,44)=-.1;
% F3(3,216)=-.1;
% F3(4,44)=-.7;
% F3(4,216)=-.1;
% F3(5,44)=-.1;
% F3(5,130)=-.1;
% F3(6,44)=-.1;
% F3(6,130)=-.1;
% 
% f_new=F1*xvartable'+F2*kron(xvartable',xvartable')+F3*kron(xvartable',kron(xvartable',xvartable'));
% 


% % N-dimensional vander pol chain example
% N = 2; n=N; deg=3;
% xvartable=[];
% for m=1:N
% c{m} = ['y',int2str(m)];
% c{m+N}=['z',int2str(m)];
% temp=pvar(c{m});
% xvartable=[xvartable temp];
% temp=pvar(c{m+N});
% xvartable=[xvartable temp];
% end
% Z=monomials(xvartable,1:deg);
% ep_c = randn(1)*0.5-1;
% 
% % dot(yi) = -2*zi                                        % i=1 to N
% % dot(zj) = 0.8*yj + 10*(1.2^2*yj^2-0.21)*zj+ep_jz(j+1)yj % j=1 to N-1
% % dot(zN) = 0.8*yN + 10*(1.2^2*yN^2-0.21)*zN
% f_new = polynomial(zeros(2*N,1));
% for m=1:2:2*N
%     f_new(m) = -2*xvartable(m+1);    % xvartable = [y1, z1, y2, z2,..., yK,zK]
% end
% for m=2:2:2*N-1
%     f_new(m) = 0.8*xvartable(m-1) + 10*(1.2^2*xvartable(m-1)^2-0.21)*xvartable(m)+ep_c*xvartable(m+2)*xvartable(m-1);
% end
% f_new(2*N) = 0.8*xvartable(end-1) + 10*(1.2^2*xvartable(end-1)^2-0.21)*xvartable(end);


n=3;deg=3;
xvartable=[];
for i=1:n
c{i}=['p',int2str(i)];
temp=pvar(c{i});
xvartable=[xvartable temp];
end
Z=monomials(xvartable,1:deg);
rng(9);
mons=randi(length(Z),n,1);
Zs=Z(mons);
f_new=-.1*jacobian(Zs,xvartable)*xvartable'-xvartable';

%f_temp=-xvartable';

disp('setting up the SOS program using pvar')
tic
prog1 = sosprogram(xvartable);
[prog1,V]=sossosvar(prog1,Z);
V=V+.001*xvartable*xvartable';
toc 
tic
Vd=jacobian(V,xvartable)*f_new;
%[prog1]=sosineq(prog1,-Vd);
%[prog1,V2]=sossosvar(prog1,Z);
toc
tic
% n=5, d=4, t=849s
[prog1]=sosineq(prog1,-Vd);
toc
disp('Solving the SOS program using pvar')
tic
prog1_s=sossolve(prog1);
toc



disp('setting up the SOS program using dpvar')
tic
prog2 = sosprogram(xvartable);
[prog2,V2]=DPsossosvar(prog2,Z);
V2=V2+.001*xvartable*xvartable';
toc 
tic
Vd2=DPjacobian(V2,xvartable)*f_new;
toc 
tic
% n=5, d=4, t=.037s
[prog2]=DPsosineq(prog2,-Vd2);
toc
disp('Solving the SOS program using dpvar')
tic
prog2_s=sossolve(prog2);
V2s=sosgetsol(prog2_s,dpvar2poly(V2));
toc


disp('setting up the SOS program using syms')
% svartable=[];
% for i=1:n
% c{i}=['s',int2str(i)];
% temp=sym(c{i});
% svartable=[svartable temp];
% end
syms s1 s2 s3 s4 s5 real;
svartable = [s1 s2 s3 s4 s5];
Z=sosmonomials(svartable,deg);
rng(9);
mons=randi(length(Z),n,1);
Zs=Z(mons);
f_new=-.1*jacobian(Zs,svartable)*svartable'-svartable';

tic
prog3 = sosprogram(svartable);
[prog3,V3]=sossosvar(prog3,Z);
V3=V3+.001*svartable*svartable';
toc 
tic
Vd3=jacobian(V3,svartable)*f_new;
toc 
tic
[prog3]=sosineq(prog3,-Vd3);
toc
disp('Solving the SOS program using dpvar')
tic
prog3_s=sossolve(prog3);
V2s=sosgetsol(prog3_s,V3);
toc
