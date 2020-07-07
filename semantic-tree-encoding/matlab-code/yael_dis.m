% Return the dis of a set of query vectors
%
% Usage: [dis] = nn(v, q, distype)
%   v                the dataset to be searched (one vector per column)
%   q                the set of queries (one query per column)
%   distype          distance type: 1=L1, 
%                                   2=L2         -> Warning: return the square L2 distance
%                                   3=chi-square -> Warning: return the square Chi-square
%                                   4=signed chis-square
%                                   16=cosine    -> Warning: return the *smallest* cosine 
%                                                   Use -query to obtain the largest
%                    available in Mex-version only
%
% Returned values
%   dis         the corresponding *square* distances
%
% Both v and q contains vectors stored in columns, so transpose them if needed
function [dis] = yael_dis (X, Q, distype)


if ~exist('distype'), distype = 2; end 
assert (size (X, 1) == size (Q, 1));

switch distype

case {2,'L2'}
  % Compute half square norm
  X_nr = sum (X.^2) / 2;
  Q_nr = sum (Q.^2) / 2;

  sim = bsxfun (@plus, Q_nr', bsxfun (@minus, X_nr, Q'*X));
%  sim = bsxfun (@minus, X_nr, Q'*X)
%  sim = bsxfun (@plus, Q_nr', sim);
  
  dis = sim' * 2;

case {16,'COS'}
  sim = Q' * X;
                 
otherwise
   error ('Unknown distance type');
end