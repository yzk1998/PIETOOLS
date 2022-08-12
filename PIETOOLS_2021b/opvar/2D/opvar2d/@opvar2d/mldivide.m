function [Xop,eps,deg_fctr_final] = mldivide(P1op,P2op,deg_fctr,tol,deg_fctr_max)
% [Xop,eps,deg_fctr_final] = mldivide(P1op,P2op,deg_fctr,tol,deg_fctr_max)
% computes an opvar2d object Xop=P1op\P2op, such that P1op*Xop = P2op.
%
% For Information, see the "mrdivide" function (for now).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C)2022  M. Peet, S. Shivakumar, D. Jagt
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% If you modify this code, document all changes carefully and include date
% authorship, and a brief description of modifications
%
% Initial "coding" DJ - 08/03/2022.

% % Very lazy implementation:
% % If    P1op * Xop = P2op,
% % then  Xop' * P1op' = P2op';
[Xop,eps,deg_fctr_final] = mrdivide(P2op',P1op',fliplr(deg_fctr),tol,fliplr(deg_fctr_max));
Xop = Xop';
deg_fctr_final = fliplr(deg_fctr_final);

end