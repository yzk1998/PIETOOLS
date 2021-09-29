function [logval, msg] = isvalid(P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [logval, msg] = isvalid(P) tests if operator 
% P: R^m0 x L2^mx x L2^my x L2^m2 to R^n0 x L2^nx x L2^ny x L2^n2
% has valid properties. The functions tests dimension compatibility and 
% object compatibility of each component.
% Date: 02/04/21
% Version: 1.0
% 
% INPUT
% P: opvar2d class object
% 
% OUTPUT
% logval: returns 0 if the object is a valid opvar
%                 1 if the object has incorrect dimensions
%                 2 if component P.R00 is not a matrix
%                 3.1 if R0x, Rx0 or Rxx{1,1} are not polynomials in ss1
%                 3.2 if R0y, Ry0 or Ryy{1,1} are not polynomials in ss2
%                 3.3 if Rxy, Ryx, Rx2{1,1}, R2x{1,1}, Ry2{1,1}, R2y{1,1}
%                       or R22{1,1} are not polynomials in (ss1,ss2)
%                 4.1 if Rxx{i,1} are not polynomials in (ss1, tt1)
%                 4.2 if Ryy{1,i} are not polynomials in (ss2, tt2)
%                 4.3 if Rx2{i,1}, R2x{i,1}, R22{i,1} are not polynomials in (ss1, ss2, tt1)
%                 4.4 if Ry2{1,i}, R2i{1,i}, R22{1,i} are not polynomials in (ss1, ss2, tt2)
%                 4.5 if R22{i,j} are not polynomials in (ss1, ss2, tt1, tt2)
% msg: type of error
% 
% NOTES:
% For support, contact M. Peet, Arizona State University at mpeet@asu.edu
% R00 , R0x , R0y , R02;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PIETools - isvalid
%
% Copyright (C)2021  M. Peet, S. Shivakumar, D. Jagt
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% If you modify this code, document all changes carefully and include date
% authorship, and a brief description of modifications
%
% Initial coding DJ - 02_04_2021  
%   ^ Based heavily on "@opvar"-isvalid code by SS ^

if ~isa(P,'opvar2d')
    error('To check validity input must be opvar2d object');
end

dim = P.dim;

R00 = P.R00;    R0x = P.R0x;    R0y = P.R0y;    R02 = P.R02;
Rx0 = P.Rx0;    Rxx = P.Rxx;    Rxy = P.Rxy;    Rx2 = P.Rx2;
Ry0 = P.Ry0;    Ryx = P.Ryx;    Ryy = P.Ryy;    Ry2 = P.Ry2;
R20 = P.R20;    R2x = P.R2x;    R2y = P.R2y;    R22 = P.R22;

opvarlistxx = [P.var1.varname(1); P.var2.varname(1)]; 
opvarlistyy = [P.var1.varname(2); P.var2.varname(2)]; 
opvarlistx2 = [P.var1.varname(:); P.var2.varname(1)]; 
opvarlisty2 = [P.var1.varname(:); P.var2.varname(2)]; 
opvarlist22 = [P.var1.varname(:); P.var2.varname(:)]; 

%%%%%%%%%%%%%%% R0.

if isa(R0x,'polynomial')
    R0xlist = R0x.varname;
    R0xdiff = setdiff(R0xlist,P.var1.varname(1));
else
    R0xdiff = {};
end
if isa(R0y,'polynomial')
    R0ylist = R0y.varname;
    R0ydiff = setdiff(R0ylist,P.var1.varname(2));
else
    R0ydiff = {};
end
if isa(R02,'polynomial')
    R02list = R02.varname;
    R02diff = setdiff(R0ylist,P.var1.varname(:));
else
    R02diff = {};
end

%%%%%%%%%%%%%%% Rx.

if isa(Rx0,'polynomial')
    Rx0list = Rx0.varname;
    Rx0diff = setdiff(Rx0list,P.var1.varname(1));
else
    Rx0diff = {};
end
Rxxdiff = cell(3,1);
if isa(Rxx{1,1},'polynomial')
    Rxxlist = Rxx{1,1}.varname;
    Rxxdiff{1} = setdiff(Rxxlist,P.var1.varname(1));
else
    Rxxdiff{1} = {};
end
for i=2:3
    if isa(Rxx{i,1},'polynomial')
        Rxxlist = Rxx{i,1}.varname;
        Rxxdiff{i} = setdiff(Rxxlist,opvarlistxx);
    else
        Rxxdiff{i} = {};
    end
end
if isa(Rxy,'polynomial')
    Rxylist = Rxy.varname;
    Rxydiff = setdiff(Rxylist,P.var1.varname(:));
else
    Rxydiff = {};
end
Rx2diff = cell(3,1);
if isa(Rx2{1,1},'polynomial')
    Rx2list = Rx2{1,1}.varname;
    Rx2diff{1} = setdiff(Rx2list,P.var1.varname(:));
else
    Rx2diff{1} = {};
end
for i=2:3
    if isa(Rx2{i,1},'polynomial')
        Rx2list = Rx2{i,1}.varname;
        Rx2diff{i} = setdiff(Rx2list,opvarlistx2);
    else
        Rx2diff{i} = {};
    end
end

%%%%%%%%%%%%%%% Ry.

if isa(Ry0,'polynomial')
    Ry0list = Ry0.varname;
    Ry0diff = setdiff(Ry0list,P.var1.varname(2));
else
    Ry0diff = {};
end
if isa(Ryx,'polynomial')
    Ryxlist = Ryx.varname;
    Ryxdiff = setdiff(Ryxlist,P.var1.varname(:));
else
    Ryxdiff = {};
end
Ryydiff = cell(1,3);
if isa(Ryy{1,1},'polynomial')
    Ryylist = Ryy{1,1}.varname;
    Ryydiff{1} = setdiff(Ryylist,P.var1.varname(2));
else
    Ryydiff{1} = {};
end
for i=2:3
    if isa(Ryy{1,i},'polynomial')
        Ryylist = Ryy{1,i}.varname;
        Ryydiff{i} = setdiff(Ryylist,opvarlistyy);
    else
        Ryydiff{i} = {};
    end
end
Ry2diff = cell(1,3);
if isa(Ry2{1,1},'polynomial')
    Ry2list = Ry2{1,1}.varname;
    Ry2diff{1} = setdiff(Ry2list,P.var1.varname(:));
else
    Ry2diff{1} = {};
end
for i=2:3
    if isa(Ry2{1,i},'polynomial')
        Ry2list = Ry2{1,i}.varname;
        Ry2diff{i} = setdiff(Ry2list,opvarlisty2);
    else
        Ry2diff{i} = {};
    end
end

%%%%%%%%%%%%%%% R2.

if isa(R20,'polynomial')
    R20list = R20.varname;
    R20diff = setdiff(R20list,P.var1.varname(:));
else
    R20diff = {};
end
R2xdiff = cell(3,1);
if isa(R2x{1,1},'polynomial')
    R2xlist = R2x{1,1}.varname;
    R2xdiff{1} = setdiff(R2xlist,P.var1.varname(:));
else
    R2xdiff{1} = {};
end
for i=2:3
    if isa(R2x{i,1},'polynomial')
        R2xlist = R2x{i,1}.varname;
        R2xdiff{i} = setdiff(R2xlist,opvarlistx2);
    else
        R2xdiff{i} = {};
    end
end
R2ydiff = cell(1,3);
if isa(R2y{1,1},'polynomial')
    R2ylist = R2y{1,1}.varname;
    R2ydiff{1} = setdiff(R2ylist,P.var1.varname(:));
else
    R2ydiff{1} = {};
end
for i=2:3
    if isa(R2y{1,i},'polynomial')
        R2ylist = R2y{1,i}.varname;
        R2ydiff{i} = setdiff(R2ylist,opvarlisty2);
    else
        R2ydiff{i} = {};
    end
end
R22diff = cell(3,3);
if isa(R22{1,1},'polynomial')
    R22list = R22{1,1}.varname;
    R22diff{1} = setdiff(R22list,P.var1.varname(:));
else
    R22diff{1} = {};
end
for i=2:3
    if isa(R22{i,1},'polynomial')
        R22list = R22{i,1}.varname;
        R22diff{i,1} = setdiff(R22list,opvarlistx2);
    else
        R22diff{i,1} = {};
    end
    if isa(R22{1,i},'polynomial')
        R22list = R22{1,i}.varname;
        R22diff{1,i} = setdiff(R22list,opvarlisty2);
    else
        R22diff{1,i} = {};
    end
    for j=2:3
        if isa(R22{i,j},'polynomial')
            R22list = R22{1,i}.varname;
            R22diff{i,j} = setdiff(R22list,opvarlist22);
        else
            R22diff{i,j} = {};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logval=0;
msg = 'Valid opvar2d';

if any(isnan(dim(:,:)),'all')
    logval=1;
    msg = 'Components have incompatible dimensions';
%%%%%%%%%%%%%%% R0.
elseif ~isa(R00,'double')
    logval=2;
    msg = 'R00 is not a matrix';
elseif ~isa(R0x,'double')&&~isempty(R0xdiff)
    logval=3.1;
    msg= 'R0x has pvars different from var1(1)';
elseif ~isa(R0y,'double')&&~isempty(R0ydiff)
    logval=3.2;
    msg= 'R0y has pvars different from var1(2)';
elseif ~isa(R02,'double')&&~isempty(R02diff)
    logval=3.3;
    msg= 'R02 has pvars different from var1(:)';
%%%%%%%%%%%%%%% Rx.    
elseif ~isa(Rx0,'double')&&~isempty(Rx0diff)
    logval=3.1;
    msg= 'Rx0 has pvars different from var1(1)';
elseif ~isa(Rxx{1,1},'double')&&~isempty(Rxxdiff{1})
    logval=3.1;
    msg= 'Rxx{1} has pvars different from var1(1)';
elseif ~isa(Rxy,'double')&&~isempty(Rxydiff)
    logval=3.2;
    msg= 'Rxy has pvars different from var1(2)';
elseif ~isa(Rx2{1,1},'double')&&~isempty(Rx2diff{1})
    logval=3.3;
    msg= 'Rx2{1} has pvars different from var1(:)';
%%%%%%%%%%%%%%% Ry.
elseif ~isa(Ry0,'double')&&~isempty(Ry0diff)
    logval=3.2;
    msg= 'Ry0 has pvars different from var1(2)';
elseif ~isa(Ryx,'double')&&~isempty(Ryxdiff)
    logval=3.3;
    msg= 'Ryx has pvars different from var1(:)';
elseif ~isa(Ryy{1,1},'double')&&~isempty(Ryydiff{1})
    logval=3.2;
    msg= 'Ryy{1} has pvars different from var1(2)';
elseif ~isa(Ry2{1,1},'double')&&~isempty(Ry2diff{1})
    logval=3.3;
    msg= 'Ry2{1} has pvars different from var1(:)';
%%%%%%%%%%%%%%% R2.
elseif ~isa(R20,'double')&&~isempty(R20diff)
    logval=3.3;
    msg= 'R20 has pvars different from var1(:)';
elseif ~isa(R2x{1,1},'double')&&~isempty(R2xdiff{1})
    logval=3.3;
    msg= 'R2x{1} has pvars different from var1(:)';
elseif ~isa(R2y{1,1},'double')&&~isempty(R2ydiff{1})
    logval=3.2;
    msg= 'R2y{1} has pvars different from var1(:)';
elseif ~isa(R22{1,1},'double')&&~isempty(R22diff{1})
    logval=3.3;
    msg= 'R22{1} has pvars different from var1(:)';
end

for i=1:3
    if ~isa(Rxx{i,1},'double') && ~isempty(Rxxdiff{i})
        logval=4.1;
        msg= ['Rxx{',num2str(i),',1} has pvars different from var1(1) and var2(1)'];
    end
    if ~isa(Ryy{1,i},'double') && ~isempty(Ryydiff{i})
        logval=4.2;
        msg= ['Ryy{1,',num2str(i),'} has pvars different from var1(2) and var2(2)'];
    end
    
    if ~isa(Rx2{i,1},'double') && ~isempty(Rx2diff{i})
        logval=4.3;
        msg= ['Rx2{',num2str(i),',1} has pvars different from var1(:) and var2(1)'];
    end
    if ~isa(R2x{i,1},'double') && ~isempty(R2xdiff{i})
        logval=4.3;
        msg= ['R2x{',num2str(i),',1} has pvars different from var1(:) and var2(1)'];
    end
    if ~isa(R22{i,1},'double') && ~isempty(R22diff{i,1})
        logval=4.3;
        msg= ['R22{',num2str(i),',1} has pvars different from var1(:) and var2(1)'];
    end
    
    if ~isa(Ry2{1,i},'double') && ~isempty(Ry2diff{i})
        logval=4.4;
        msg= ['Ry2{1,',num2str(i),'} has pvars different from var1(:) and var2(2)'];
    end
    if ~isa(R2y{1,i},'double') && ~isempty(R2ydiff{i})
        logval=4.4;
        msg= ['R2y{1,',num2str(i),'} has pvars different from var1(:) and var2(2)'];
    end
    if ~isa(R22{1,i},'double') && ~isempty(R22diff{1,i})
        logval=4.4;
        msg= ['R22{1,',num2str(i),'} has pvars different from var1(:) and var2(2)'];
    end
    
    for j=1:3
        if ~isa(R22{i,j},'double') && ~isempty(R22diff{i,j})
            logval=4.5;
            msg= ['R22{',num2str(i),',',num2str(j),'} has pvars different from var1(:) and var2(:)'];
        end
    end
end


end
