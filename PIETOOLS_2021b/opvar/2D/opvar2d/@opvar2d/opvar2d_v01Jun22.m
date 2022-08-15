classdef (InferiorClasses={?dpvar,?polynomial}) opvar2d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This defines the class of operator variables 
%   P: R^m0 x L2^mx x L2^my x L2^m2 to R^n0 x L2^nx x L2^ny x L2^n2
% Date: 01/31/21
% Version: 1.0
% 
% CLASS properties
% P.dim: a 4x2 array with entries [n0,m0]
%                                 [nx,mx]
%                                 [ny,my]
%                                 [n2,m2]

% P.R00: a n0 x m0 matrix
% P.R0x: a n0 x mx matrix valued polynomial in ss1
% P.R0y: a n0 x my matrix valued polynomial in ss2
% P.R02: a n0 x m2 matrix valued polynomial in ss1, ss2

% P.Rx0: a nx x m0 matrix valued polynomial in ss1
% P.Rxx: 3x1 cell of nx x mx matrix valued polynomials in ss1, tt1
% P.Rxy: a nx x my matrix valued polynomial in ss1, ss2
% P.Rx2: 3x1 cell of nx x m2 matrix valued polynomials in ss1, tt1, ss2

% P.Ry0: a ny x m0 matrix valued polynomial in ss2
% P.Ryx: a ny x mx matrix valued polynomial in ss1, ss2
% P.Ryy: 1x3 cell of ny x my matrix valued polynomials in ss2, tt2
% P.Ry2: 1x3 cell ny x m2 matrix valued polynomials in ss1, ss2, tt2

% P.R20: a n2 x m0 matrix valued polynomial in ss1, ss2
% P.R2x: 3x1 cell of n2 x mx matrix valued polynomials in ss1, tt1, ss2
% P.R2y: 1x3 cell fo n2 x my matrix valued polynomials in ss1, ss2, tt2
% P.R22: 3x3 cell of n2 x m2 matrix valued polynomials in ss1, tt1, ss2, tt2

% P.I: domain    
% P.var1: polynomial variables ss1, ss2, (internal property, recommend not to modify)
% P.var2: polynomial variables tt1, tt2 (internal property, recommend not to modify)
%
% NOTES:
% For support, contact M. Peet, Arizona State University at mpeet@asu.edu
% or D. Jagt at djagt@asu.edu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PIETools - opvar2d
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
% Initial coding DJ - 01_31_2021  
%   ^ Based heavily on "@opvar"-opvar code by SS ^



    properties
        R00 = [];
        R0x = polynomial([]);
        R0y = polynomial([]);
        R02 = polynomial([]);
        
        Rx0 = polynomial([]);
        Rxx = {polynomial([]); polynomial([]); polynomial([])};
        Rxy = polynomial([]);
        Rx2 = {polynomial([]); polynomial([]); polynomial([])};
        
        Ry0 = polynomial([]);
        Ryx = polynomial([]);
        Ryy = {polynomial([]), polynomial([]), polynomial([])};
        Ry2 = {polynomial([]), polynomial([]), polynomial([])};
        
        R20 = polynomial([]);
        R2x = {polynomial([]); polynomial([]); polynomial([])};
        R2y = {polynomial([]), polynomial([]), polynomial([])};
        R22 = {polynomial([]), polynomial([]), polynomial([]);
               polynomial([]), polynomial([]), polynomial([]);
               polynomial([]), polynomial([]), polynomial([])};
        
        I = [0,1;0,1];
        var1 = [pvar('ss1'); pvar('ss2')];
        var2 = [pvar('tt1'); pvar('tt2')];
        dim = zeros(4,2);
    end
    
    properties (Dependent)
        dimdependent;
    end
    
    methods
        function [P] = opvar2d(varargin) %constructor
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin==1
                if ischar(varargin{1})
                    if nargout==0
                        assignin('caller', varargin{1}, opvar2d());
                    end
                elseif isa(varargin{1},'double') && nargout==1
                    if ~any(size(varargin{1})==[4,2])
                        error('dimension of opvar2d must be a 4x2 integer array')
                    else
                        P = opvar2d();
                        P = set(P,'dim',varargin{1});
                        %P = opvar2d(zeros(sum(varargin{1},1)),varargin{1});
                        %P.dim = varargin{1};
                    end
                elseif isa(varargin{1},'opvar2d') && nargout==1
                    P = varargin{1};
                    % Check if the produced object is valid
                    [logval,msg] = isvalid(P);
                    if ~logval
                        error(['The input is not a valid opvar2d object: ',msg]);
                    end
                elseif isa(varargin{1},'dopvar2d') && nargout==1
                    P = dopvar2opvar2d(varargin{1});
                else
                    error("Single input must be string, integer double, or dopvar2d object");
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif nargin==2
                if isa(varargin{1},'opvar2d') && isnumeric(varargin{2})
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~all(varargin{1}.dim==varargin{2})
                        error('The size of the opvar2d input does not match the proposed dimensions')
                    else
                        % Return the input object
                        P = varargin{1};
                        % Check if the produced object is valid
                        [logval,msg] = isvalid(P);
                        if ~logval
                            error(['The input is not a valid opvar2d object: ',msg]);
                        end
                    end
                elseif (isa(varargin{1},'double') && all(size(varargin{1})==[4,2])) && ...
                            (isa(varargin{2},'double') && all(size(varargin{2})==[2,2]))
                    % Build empty opvar2d of dimension varargin{1} on
                    % domain varargin{2}
                    P = opvar2d();
                    P.dim = varargin{1};
                    P.I = varargin{2};
                    % Check if the produced object is valid
                    [logval,msg] = isvalid(P);
                    if ~logval
                        %fprintf(2,['\n > > >  Warning: ',msg,'  < < < \n'])
                        error(['A valid opvar2d object cannot be constructed from the provided inputs: ',msg]);
                    end
                elseif (isa(varargin{1},'double') || isa(varargin{1},'polynomial')) && isnumeric(varargin{2})
                    % Build opvar2d from matrix varargin{1} based on
                    % dimensions varargin{2}
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~(all(sum(varargin{2},1)==size(varargin{1})) || isempty(varargin{1}))
                        error('Dimension of desired opvar2d should match dimension of the input matrix')
                    else
                        P = opvar2d();
                        P.dim = varargin{2};
                        if ~isempty(varargin{1})
                            % Set the parameters based on value of first argument
                            mat = varargin{1};
                            rind = cumsum(P.dim(:,1));  
                            cind = cumsum(P.dim(:,2));
                            
                            P.R00 = polynomial(mat(1:rind(1),1:cind(1)));
                            P.Rx0 = polynomial(mat(rind(1)+1:rind(2),1:cind(1)));
                            P.Ry0 = polynomial(mat(rind(2)+1:rind(3),1:cind(1)));
                            P.R20 = polynomial(mat(rind(3)+1:rind(4),1:cind(1)));

                            P.R0x = polynomial(mat(1:rind(1),cind(1)+1:cind(2)));
                            P.Rxx{1} = polynomial(mat(rind(1)+1:rind(2),cind(1)+1:cind(2)));
                            P.Ryx = polynomial(mat(rind(2)+1:rind(3),cind(1)+1:cind(2)));
                            P.R2x{1} = polynomial(mat(rind(3)+1:rind(4),cind(1)+1:cind(2)));

                            P.R0y = polynomial(mat(1:rind(1),cind(2)+1:cind(3)));
                            P.Rxy = polynomial(mat(rind(1)+1:rind(2),cind(2)+1:cind(3)));
                            P.Ryy{1} = polynomial(mat(rind(2)+1:rind(3),cind(2)+1:cind(3)));
                            P.R2y{1} = polynomial(mat(rind(3)+1:rind(4),cind(2)+1:cind(3)));

                            P.R02 = polynomial(mat(1:rind(1),cind(3)+1:cind(4)));
                            P.Rx2{1} = polynomial(mat(rind(1)+1:rind(2),cind(3)+1:cind(4)));
                            P.Ry2{1} = polynomial(mat(rind(2)+1:rind(3),cind(3)+1:cind(4)));
                            P.R22{1,1} = polynomial(mat(rind(3)+1:rind(4),cind(3)+1:cind(4)));

                            % Check if the produced object is valid
                            [logval,msg] = isvalid(P);
                            if ~logval
                                %fprintf(2,['\n > > >  Warning: ',msg,'  < < < \n'])
                                error(['A valid opvar2d object cannot be constructed from the provided inputs: ',msg]);
                            end
                        end
                    end
                else
                    for i=1:nargin
                        if ischar(varargin{i})
                            if nargout==0
                                assignin('caller', varargin{i}, opvar2d());
                            end
                        else
                            error("Input must be strings");
                        end
                    end
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif nargin==3
                if isa(varargin{1},'opvar2d') && isnumeric(varargin{2})
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~all(varargin{1}.dim==varargin{2})
                        error('The size of the opvar2d input does not match the proposed dimensions')
                    elseif ~all(varargin{1}.I==varargin{3})
                        error('The domain of the opvar2d input does not match the proposed domain')
                    else
                        % Return the input object
                        P = varargin{1};
                        % Check if the produced object is valid
                        [logval,msg] = isvalid(P);
                        if ~logval
                            error(['The input is not a valid opvar2d object: ',msg]);
                        end
                    end
                elseif (isa(varargin{1},'double') && all(size(varargin{1})==[4,2])) && ...
                        (isa(varargin{2},'double') && all(size(varargin{2})==[2,2])) && ...
                         (ispvar(varargin{3}) && ((prod(size(varargin{3}))==4) || (prod(size(varargin{3}))==2)))
                    % Build empty opvar2d of dimension varargin{1} on
                    % domain varargin{2} in variables varargin{3}
                    P = opvar2d();
                    P.dim = varargin{1};
                    P.I = varargin{2};
                    P.var1 = [varargin{3}(1);varargin{3}(2)];
                    if prod(size(varargin{3}))==4
                        P.var2 = [varargin{3}(3);varargin{3}(4)];
                    end
                    % Check if the produced object is valid
                    [logval,msg] = isvalid(P);
                    if ~logval
                        %fprintf(2,['\n > > >  Warning: ',msg,'  < < < \n'])
                        error(['A valid opvar2d object cannot be constructed from the provided inputs: ',msg]);
                    end
                elseif (isa(varargin{1},'double') || isa(varargin{1},'polynomial')) && isnumeric(varargin{2})
                    % Build opvar2d from matrix varargin{1} based on
                    % dimensions varargin{2}, and with domain varargin{3}.
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~(all(sum(varargin{2},1)==size(varargin{1})) || isempty(varargin{1}))
                        error('Dimension of desired opvar2d should match dimension of the input matrix')
                    elseif ~isnumeric(varargin{3}) || ~all(size(varargin{3})==[2,2])
                        error('Domain should be specified as a 2x2 array')
                    else
                        P = opvar2d();
                        P.I = varargin{3};
                        P.dim = varargin{2};
                        
                        if ~isempty(varargin{1})
                            % Set the parameters based on value of first argument
                            mat = varargin{1};
                            rind = cumsum(P.dim(:,1));  
                            cind = cumsum(P.dim(:,2));

                            P.R00 = polynomial(mat(1:rind(1),1:cind(1)));
                            P.Rx0 = polynomial(mat(rind(1)+1:rind(2),1:cind(1)));
                            P.Ry0 = polynomial(mat(rind(2)+1:rind(3),1:cind(1)));
                            P.R20 = polynomial(mat(rind(3)+1:rind(4),1:cind(1)));

                            P.R0x = polynomial(mat(1:rind(1),cind(1)+1:cind(2)));
                            P.Rxx{1} = polynomial(mat(rind(1)+1:rind(2),cind(1)+1:cind(2)));
                            P.Ryx = polynomial(mat(rind(2)+1:rind(3),cind(1)+1:cind(2)));
                            P.R2x{1} = polynomial(mat(rind(3)+1:rind(4),cind(1)+1:cind(2)));

                            P.R0y = polynomial(mat(1:rind(1),cind(2)+1:cind(3)));
                            P.Rxy = polynomial(mat(rind(1)+1:rind(2),cind(2)+1:cind(3)));
                            P.Ryy{1} = polynomial(mat(rind(2)+1:rind(3),cind(2)+1:cind(3)));
                            P.R2y{1} = polynomial(mat(rind(3)+1:rind(4),cind(2)+1:cind(3)));

                            P.R02 = polynomial(mat(1:rind(1),cind(3)+1:cind(4)));
                            P.Rx2{1} = polynomial(mat(rind(1)+1:rind(2),cind(3)+1:cind(4)));
                            P.Ry2{1} = polynomial(mat(rind(2)+1:rind(3),cind(3)+1:cind(4)));
                            P.R22{1,1} = polynomial(mat(rind(3)+1:rind(4),cind(3)+1:cind(4)));

                            % Check if the produced object is valid
                            [logval,msg] = isvalid(P);
                            if ~logval
                                %fprintf(2,['\n > > >  Warning: ',msg,'  < < < \n'])
                                error(['A valid opvar2d object cannot be constructed from the provided inputs: ',msg]);
                            end
                        end
                    end                    
                else
                    for i=1:nargin
                        if ischar(varargin{i})
                            if nargout==0
                                assignin('caller', varargin{i}, opvar2d());
                            end
                        else
                            error("Input must be strings");
                        end
                    end
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif nargin==4
                if isa(varargin{1},'opvar2d') && isnumeric(varargin{2})
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~all(varargin{1}.dim==varargin{2})
                        error('The size of the opvar2d input does not match the proposed dimensions')
                    elseif ~all(varargin{1}.I==varargin{3})
                        error('The domain of the opvar2d input does not match the proposed domain')
                    elseif ~all(size(varargin{4})==[2,2]) && ~all(size(varargin{4})==[2,1])
                        error('Variables of the opvar2d should be specified as 2x2 pvar class object')
                    elseif all(size(varargin{4})==[2,2]) && ~all(all(isequal([varargin{1}.var1,varargin{1}.var2],varargin{4})))
                        error('The variables of the opvar2d input do not match the proposed variables')
                    elseif all(size(varargin{4})==[2,1]) && ~all(isequal(varargin{1}.var1,varargin{4}))
                        error('The variables of the opvar2d input do not match the proposed variables')
                    else
                        % Return the input object
                        P = varargin{1};
                        % Check if the produced object is valid
                        [logval,msg] = isvalid(P);
                        if ~logval
                            error(['The input is not a valid opvar2d object: ',msg]);
                        end
                    end
                elseif (isa(varargin{1},'double') && all(size(varargin{1})==[4,2])) && ...
                        (isa(varargin{2},'double') && all(size(varargin{2})==[2,2])) && ...
                         (ispvar(varargin{3}) && (prod(size(varargin{3}))==2)) && ...
                          (ispvar(varargin{4}) && (prod(size(varargin{4}))==2))
                    % Build empty opvar2d of dimension varargin{1} on
                    % domain varargin{2} in variables varargin{3}
                    P = opvar2d();
                    P.dim = varargin{1};
                    P.I = varargin{2};
                    P.var1 = [varargin{3}(1);varargin{3}(2)];
                    P.var2 = [varargin{4}(1);varargin{4}(2)];
                    % Check if the produced object is valid
                    [logval,msg] = isvalid(P);
                    if ~logval
                        %fprintf(2,['\n > > >  Warning: ',msg,'  < < < \n'])
                        error(['A valid opvar2d object cannot be constructed from the provided inputs: ',msg]);
                    end
                elseif (isa(varargin{1},'double') || isa(varargin{1},'polynomial')) && isnumeric(varargin{2})
                    % Build opvar2d from matrix varargin{1} based on
                    % dimensions varargin{2}, and with domain varargin{3}.
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~(all(sum(varargin{2},1)==size(varargin{1})) || isempty(varargin{1}))
                        error('Dimension of desired opvar2d should match dimension of the input matrix')
                    elseif ~isnumeric(varargin{3}) || ~all(size(varargin{3})==[2,2])
                        error('Domain should be specified as a 2x2 array')
                    elseif ~ispvar(varargin{4}) || (~(prod(size(varargin{4}))==4) && ~(prod(size(varargin{4}))==2))
                        error('Variables should be specified as 2x2 pvar class object')
                    else
                        P = opvar2d();
                        P.I = varargin{3};
                        P.dim = varargin{2};
                        P.var1 = [varargin{4}(1);varargin{4}(2)];
                        if prod(size(varargin{4}))==4
                            P.var2 = [varargin{4}(3);varargin{4}(4)];
                        end
                        % Set the parameters based on value of first argument
                        if ~isempty(varargin{1})
                            mat = varargin{1};
                            rind = cumsum(P.dim(:,1));  
                            cind = cumsum(P.dim(:,2));

                            P.R00 = polynomial(mat(1:rind(1),1:cind(1)));
                            P.Rx0 = polynomial(mat(rind(1)+1:rind(2),1:cind(1)));
                            P.Ry0 = polynomial(mat(rind(2)+1:rind(3),1:cind(1)));
                            P.R20 = polynomial(mat(rind(3)+1:rind(4),1:cind(1)));

                            P.R0x = polynomial(mat(1:rind(1),cind(1)+1:cind(2)));
                            P.Rxx{1} = polynomial(mat(rind(1)+1:rind(2),cind(1)+1:cind(2)));
                            P.Ryx = polynomial(mat(rind(2)+1:rind(3),cind(1)+1:cind(2)));
                            P.R2x{1} = polynomial(mat(rind(3)+1:rind(4),cind(1)+1:cind(2)));

                            P.R0y = polynomial(mat(1:rind(1),cind(2)+1:cind(3)));
                            P.Rxy = polynomial(mat(rind(1)+1:rind(2),cind(2)+1:cind(3)));
                            P.Ryy{1} = polynomial(mat(rind(2)+1:rind(3),cind(2)+1:cind(3)));
                            P.R2y{1} = polynomial(mat(rind(3)+1:rind(4),cind(2)+1:cind(3)));

                            P.R02 = polynomial(mat(1:rind(1),cind(3)+1:cind(4)));
                            P.Rx2{1} = polynomial(mat(rind(1)+1:rind(2),cind(3)+1:cind(4)));
                            P.Ry2{1} = polynomial(mat(rind(2)+1:rind(3),cind(3)+1:cind(4)));
                            P.R22{1,1} = polynomial(mat(rind(3)+1:rind(4),cind(3)+1:cind(4)));

                            % Check if the produced object is valid
                            [logval,msg] = isvalid(P);
                            if ~logval
                                %fprintf(2,['\n > > >  Warning: ',msg,'  < < < \n'])
                                error(['A valid opvar2d object cannot be constructed from the provided inputs: ',msg]);
                            end
                        end
                    end
                else
                    for i=1:nargin
                        if ischar(varargin{i})
                            if nargout==0
                                assignin('caller', varargin{i}, opvar2d());
                            end
                        else
                            error("Input must be strings");
                        end
                    end
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif nargin==5
                if isa(varargin{1},'opvar2d') && isnumeric(varargin{2})
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~all(varargin{1}.dim==varargin{2})
                        error('The size of the opvar2d input does not match the proposed dimensions')
                    elseif ~all(varargin{1}.I==varargin{3})
                        error('The domain of the opvar2d input does not match the proposed domain')
                    elseif ~all(size(varargin{4})==[2,1]) || ~all(size(varargin{5})==[2,1])
                        error('Variables of the opvar2d should be specified as two 2x1 pvar class object')
                    elseif ~all(isequal(varargin{1}.var1,varargin{4}))
                        error('The primary variables of the opvar2d input do not match the proposed variables')
                    elseif ~all(isequal(varargin{1}.var2,varargin{5}))
                        error('The secondary variables of the opvar2d input do not match the proposed variables')
                    else
                        % Return the input object
                        P = varargin{1};
                        % Check if the produced object is valid
                        [logval,msg] = isvalid(P);
                        if ~logval
                            error(['The input is not a valid opvar2d object: ',msg]);
                        end
                    end
                elseif (isa(varargin{1},'double') || isa(varargin{1},'polynomial')) && isnumeric(varargin{2})
                    % Build opvar2d from matrix varargin{1} based on
                    % dimensions varargin{2}, and with domain varargin{3}.
                    if ~all(size(varargin{2})==[4,2])
                        error('Dimension of opvar2d must be a 4x2 integer array')
                    elseif ~(all(sum(varargin{2},1)==size(varargin{1})) || isempty(varargin{1}))
                        error('Dimension of desired opvar2d should match dimension of the input matrix')
                    elseif ~isnumeric(varargin{3}) || ~all(size(varargin{3})==[2,2])
                        error('Domain should be specified as a 2x2 array')
                    elseif ~ispvar(varargin{4}) || ~(prod(size(varargin{4}))==2) || ...
                                ~ispvar(varargin{5}) || ~(prod(size(varargin{5}))==2)
                        error('Variables should be specified as two 2x1 pvar class object')
                    else
                        P = opvar2d();
                        P.I = varargin{3};
                        P.dim = varargin{2};
                        P.var1 = [varargin{4}(1);varargin{4}(2)];
                        P.var2 = [varargin{5}(1);varargin{5}(2)];
                        
                        % Set the parameters based on value of first argument
                        if ~isempty(varargin{1})
                            mat = varargin{1};
                            rind = cumsum(P.dim(:,1));  
                            cind = cumsum(P.dim(:,2));

                            P.R00 = polynomial(mat(1:rind(1),1:cind(1)));
                            P.Rx0 = polynomial(mat(rind(1)+1:rind(2),1:cind(1)));
                            P.Ry0 = polynomial(mat(rind(2)+1:rind(3),1:cind(1)));
                            P.R20 = polynomial(mat(rind(3)+1:rind(4),1:cind(1)));

                            P.R0x = polynomial(mat(1:rind(1),cind(1)+1:cind(2)));
                            P.Rxx{1} = polynomial(mat(rind(1)+1:rind(2),cind(1)+1:cind(2)));
                            P.Ryx = polynomial(mat(rind(2)+1:rind(3),cind(1)+1:cind(2)));
                            P.R2x{1} = polynomial(mat(rind(3)+1:rind(4),cind(1)+1:cind(2)));

                            P.R0y = polynomial(mat(1:rind(1),cind(2)+1:cind(3)));
                            P.Rxy = polynomial(mat(rind(1)+1:rind(2),cind(2)+1:cind(3)));
                            P.Ryy{1} = polynomial(mat(rind(2)+1:rind(3),cind(2)+1:cind(3)));
                            P.R2y{1} = polynomial(mat(rind(3)+1:rind(4),cind(2)+1:cind(3)));

                            P.R02 = polynomial(mat(1:rind(1),cind(3)+1:cind(4)));
                            P.Rx2{1} = polynomial(mat(rind(1)+1:rind(2),cind(3)+1:cind(4)));
                            P.Ry2{1} = polynomial(mat(rind(2)+1:rind(3),cind(3)+1:cind(4)));
                            P.R22{1,1} = polynomial(mat(rind(3)+1:rind(4),cind(3)+1:cind(4)));

                            % Check if the produced object is valid
                            [logval,msg] = isvalid(P);
                            if ~logval
                                %fprintf(2,['\n > > >  Warning: ',msg,'  < < < \n'])
                                error(['A valid opvar2d object cannot be constructed from the provided inputs: ',msg]);
                            end
                        end
                    end
                else
                    for i=1:nargin
                        if ischar(varargin{i})
                            if nargout==0
                                assignin('caller', varargin{i}, opvar2d());
                            end
                        else
                            error("Input must be strings");
                        end
                    end
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            else
                for i=1:nargin
                    if ischar(varargin{i})
                        if nargout==0
                            assignin('caller', varargin{i}, opvar2d());
                        end
                    else
                        error("Input must be strings");
                    end
                end
            end
        end
% % % =============================================================== % % %        
%         function [obj] = set.R00(obj,R00)
%             obj = set(obj,'R00',R00);
%             %obj.R00 = R00;
%         end
%         function [obj] = set.R0x(obj,R0x) 
%             obj.R0x = R0x;
%         end
%         function [obj] = set.R0y(obj,R0y) 
%             obj.R0y = R0y;
%         end
%         function [obj] = set.R02(obj,R02) 
%             obj.R02 = R02;
%         end
%         
%         function [obj] = set.Rx0(obj,Rx0) 
%             obj.Rx0 = Rx0;
%         end
%         function [obj] = set.Rxx(obj,Rxx) 
%             obj.Rxx = Rxx;
%         end
%         function [obj] = set.Rxy(obj,Rxy) 
%             obj.Rxy = Rxy;
%         end
%         function [obj] = set.Rx2(obj,Rx2) 
%             obj.Rx2 = Rx2;
%         end
%         
%         function [obj] = set.Ry0(obj,Ry0) 
%             obj.Ry0 = Ry0;
%         end
%         function [obj] = set.Ryx(obj,Ryx) 
%             obj.Ryx = Ryx;
%         end
%         function [obj] = set.Ryy(obj,Ryy) 
%             obj.Ryy = Ryy;
%         end
%         function [obj] = set.Ry2(obj,Ry2) 
%             obj.Ry2 = Ry2;
%         end
%         
%         function [obj] = set.R20(obj,R20) 
%             obj.R20 = R20;
%         end
%         function [obj] = set.R2x(obj,R2x) 
%             obj.R2x = R2x;
%         end
%         function [obj] = set.R2y(obj,R2y) 
%             obj.R2y = R2y;
%         end
%         function [obj] = set.R22(obj,R22) 
%             obj.R22 = R22;
%         end
        
        function [d] = get.dimdependent(obj)
            % for consistent dimensions following vectors should have
            % all values in each of them to be equal or zero.
            N0 = [size(obj.R00,1); size(obj.R0x,1); size(obj.R0y,1); size(obj.R02,1)];
            Nx = [size(obj.Rx0,1); size(obj.Rxy,1);
                  size(obj.Rxx{1},1); size(obj.Rxx{2},1); size(obj.Rxx{3},1);
                  size(obj.Rx2{1},1); size(obj.Rx2{2},1); size(obj.Rx2{3},1)];
            Ny = [size(obj.Ry0,1); size(obj.Ryx,1);
                  size(obj.Ryy{1},1); size(obj.Ryy{2},1); size(obj.Ryy{3},1);
                  size(obj.Ry2{1},1); size(obj.Ry2{2},1); size(obj.Ry2{3},1)];
            N2 = [size(obj.R20,1); 
                  size(obj.R2x{1},1); size(obj.R2x{2},1); size(obj.R2x{3},1);
                  size(obj.R2y{1},1); size(obj.R2y{2},1); size(obj.R2y{3},1);
                  size(obj.R22{1,1},1); size(obj.R22{1,2},1); size(obj.R22{1,3},1);
                  size(obj.R22{2,1},1); size(obj.R22{2,2},1); size(obj.R22{2,3},1);
                  size(obj.R22{3,1},1); size(obj.R22{3,2},1); size(obj.R22{3,3},1)];
                                
            M0 = [size(obj.R00,2); size(obj.Rx0,2); size(obj.Ry0,2); size(obj.R20,2)];
            Mx = [size(obj.R0x,2); size(obj.Ryx,2);
                size(obj.Rxx{1},2); size(obj.Rxx{2},2); size(obj.Rxx{3},2);
                size(obj.R2x{1},2); size(obj.R2x{2},2); size(obj.R2x{3},2)];
            My = [size(obj.R0y,2); size(obj.Rxy,2);
                size(obj.Ryy{1},2); size(obj.Ryy{2},2); size(obj.Ryy{3},2);
                size(obj.R2y{1},2); size(obj.R2y{2},2); size(obj.R2y{3},2)];
            M2 = [size(obj.R02,2); 
                size(obj.Rx2{1},2); size(obj.Rx2{2},2); size(obj.Rx2{3},2);
                size(obj.Ry2{1},2); size(obj.Ry2{2},2); size(obj.Ry2{3},2);
                size(obj.R22{1,1},2); size(obj.R22{1,2},2); size(obj.R22{1,3},2);
                size(obj.R22{2,1},2); size(obj.R22{2,2},2); size(obj.R22{2,3},2);
                size(obj.R22{3,1},2); size(obj.R22{3,2},2); size(obj.R22{3,3},2)];
            
            N0 = N0(N0~=0);
            if isempty(N0)
                n0=0;
            elseif all(N0/max(N0)==1)
                n0 = max(N0);
            else
                n0 = nan;
            end
            Nx = Nx(Nx~=0);
            if isempty(Nx)
                nx=0;
            elseif all(Nx/max(Nx)==1)
                nx = max(Nx);
            else
                nx = nan;
            end
            Ny = Ny(Ny~=0);
            if isempty(Ny)
                ny=0;
            elseif all(Ny/max(Ny)==1)
                ny = max(Ny);
            else
                ny = nan;
            end
            N2 = N2(N2~=0);
            if isempty(N2)
                n2=0;
            elseif all(N2/max(N2)==1)
                n2 = max(N2);
            else
                n2 = nan;
            end
            
            M0 = M0(M0~=0);
            if isempty(M0)
                m0=0;
            elseif all(M0/max(M0)==1)
                m0 = max(M0);
            else
                m0 = nan;
            end
            Mx = Mx(Mx~=0);
            if isempty(Mx)
                mx=0;
            elseif all(Mx/max(Mx)==1)
                mx = max(Mx);
            else
                mx = nan;
            end
            My = My(My~=0);
            if isempty(My)
                my=0;
            elseif all(My/max(My)==1)
                my = max(My);
            else
                my = nan;
            end
            M2 = M2(M2~=0);
            if isempty(M2)
                m2=0;
            elseif all(M2/max(M2)==1)
                m2 = max(M2);
            else
                m2 = nan;
            end
                       
            d = [n0 m0; nx mx; ny my; n2 m2];
        end
        
        function [val] = get.dim(obj)
            val = obj.dimdependent;
        end
%         function [obj] = set.dim(obj,val)
%             obj.dim = val;
%             if isempty(obj.R00)
%                 obj.R00 = polynomial(zeros(val(1,:)));
%             end
%             if isempty(obj.R0x)
%                 obj.R0x = polynomial(zeros(val(1,1),val(2,2)));
%             end
%             if isempty(obj.R0y)
%                 obj.R0y = polynomial(zeros(val(1,1),val(3,2)));
%             end
%             if isempty(obj.R02)
%                 obj.R02 = polynomial(zeros(val(1,1),val(4,2)));
%             end
%             if isempty(obj.Rx0)
%                 obj.Rx0 = polynomial(zeros(val(2,1),val(1,2)));
%             end
%             if isempty(obj.Rxy)
%                 obj.Rxy = polynomial(zeros(val(2,1),val(3,2)));
%             end
%             if isempty(obj.Ry0)
%                 obj.Ry0 = polynomial(zeros(val(3,1),val(1,2)));
%             end
%             if isempty(obj.Ryx)
%                 obj.Ryx = polynomial(zeros(val(3,1),val(2,2)));
%             end
%             if isempty(obj.R20)
%                 obj.R20 = polynomial(zeros(val(4,1),val(1,2)));
%             end
%             
%             for i=1:3
%                 if isempty(obj.Rxx{i,1})
%                     obj.Rxx{i,1} = polynomial(zeros(val(2,:)));
%                 end          
%                 if isempty(obj.Rx2{i,1})
%                     obj.Rx2{i,1} = polynomial(zeros(val(2,1),val(4,2)));
%                 end
%                 
%                 if isempty(obj.Ryy{1,i})
%                     obj.Ryy{1,i} = polynomial(zeros(val(3,:)));
%                 end
%                 if isempty(obj.Ry2{1,i})
%                     obj.Ry2{1,i} = polynomial(zeros(val(3,1),val(4,2)));
%                 end           
%             
%                 if isempty(obj.R2x{i,1})
%                     obj.R2x{i,1} = polynomial(zeros(val(4,1),val(2,2)));
%                 end
%                 if isempty(obj.R2y{1,i})
%                     obj.R2y{1,i} = polynomial(zeros(val(4,1),val(3,2)));
%                 end
%                 
%                 for j=1:3
%                     if isempty(obj.R22{i,j})
%                         obj.R22{i,j} = polynomial(zeros(val(4,:)));
%                     end
%                 end
%             end
%             
%         end
    end
end