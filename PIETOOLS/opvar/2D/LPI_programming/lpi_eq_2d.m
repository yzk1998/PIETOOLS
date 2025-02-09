function sos = lpi_eq_2d(sos,P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sos = lpi_eq_2d(prog,P) sets up equality constraints for each component.
% P.R00 = 0     P.R0x = 0       P.R0y = 0       P.R02 = 0
% P.Rx0 = 0     P.Rxx{i} = 0    P.Rxy = 0       P.Rx2{i} = 0
% P.Ry0 = 0     P.Ryx = 0       P.Ryy{j} = 0    P.Ry2{j} = 0
% P.R20 = 0     P.R2x{i} = 0    P.R2y{j} = 0    P.R22{i,j} = 0
%
% INPUT
%   prog: SOS program to modify.
%   P: PI dopvar2d variable
% OUTPUT 
%   sos: SOS program
% 
% NOTES:
% For support, contact M. Peet, Arizona State University at mpeet@asu.edu,
% S. Shivakumar at sshivak8@asu.edu, or D. Jagt at djagt@asu.edu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PIETools - lpi_eq_2d
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
% Initial coding DJ  - 07_21_2021
%
for f = {'R00','R0x','R0y','R02','Rx0','Rxy','Ry0','Ryx','R20'}
    if ~isempty(P.(f{:}))
        sos = soseq(sos, P.(f{:}));
    end
end
for i=1:3
    if ~isempty(P.Rxx{i,1}) && any(any(P.Rxx{i}.C))
        sos = soseq(sos, P.Rxx{i,1});
    end
    if ~isempty(P.Rx2{i,1}) && any(any(P.Rx2{i}.C))
        sos = soseq(sos, P.Rx2{i,1});
    end
    if ~isempty(P.R2x{i,1}) && any(any(P.R2x{i}.C))
        sos = soseq(sos, P.R2x{i,1});
    end
    
    if ~isempty(P.Ryy{1,i}) && any(any(P.Ryy{i}.C))
        sos = soseq(sos, P.Ryy{1,i});
    end
    if ~isempty(P.Ry2{1,i}) && any(any(P.Ry2{i}.C))
        sos = soseq(sos, P.Ry2{1,i});
    end
    if ~isempty(P.R2y{1,i}) && any(any(P.R2y{i}.C))
        sos = soseq(sos, P.R2y{1,i});
    end
    
    for j=1:3
        if ~isempty(P.R22{i,j}) && any(any(P.R22{i,j}.C))
            sos = soseq(sos, P.R22{i,j});
        end
    end
end
end