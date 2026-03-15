
array[0..15] of var 0..15: perm = array1d(0..15, [0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15]);
array[4..6, 0..15] of var 0..2: dX;
array[4..5, 0..15] of var 0..2: dY;
% condition for the toy example
constraint forall(i in 0..15)(dX[4,i] = bool2int(i in {1,2,8,9,11}));

% Sbox
constraint forall(r in 4..5, c in [0,4,8,12])(
  forall(j in 0..3)(dY[r,c+j] = 2 * bool2int(exists(j2 in 0..3)(dX[r,c+j2]>0)))
);

% permutation
constraint forall(r in 4..5, i in 0..15)(
  dX[r+1,perm[i]] = dY[r,i]
);

% -----------
array[4..6,0..15] of var 0..1: invX;
array[4..5,0..15] of var 0..1: invY;
array[4..5,0..15] of var 0..1: invK;

% involvement propagation
constraint forall(r in 4..6, i in 0..15)(invX[r,i] = (dX[r,i]>0)); % initialization

% Sbox
constraint forall(r in 4..5, c in [0,4,8,12])(
  forall(i in 0..3)(invY[r,c+i] = 
		    exists(j in 0..3)(invX[r,j]=1))
);
% Collect involved key
constraint forall(r in 5..6, i in 0..15)(invK[r-1,i] = invX[r,i]);


% ----------------
array[4..6, 0..15] of var 0..1: detX;
array[4..6, 0..15] of var 0..1: detY;
array[4..5, 0..15] of var 0..1: gusK;

constraint forall(i in 0..15)(detX[6,i] = 1);

% guess key and determine state
constraint forall(r in 4..5, i in 0..15)(
  detY[r, perm[i]] = detX[r+1,i] * gusK[r,i]
);

% propagation
constraint forall(r in 4..5, c in [0,4,8,12])(
  sum(i in 0..3)(detX[r,c+i]) = 4 * (sum(j in 0..3)(detY[r,c+j]) = 4)
);
% --------------

% filter from SB
array[4..5,0..3] of var int: frSB;

constraint forall(r in 4..5, c in 0..3)(
  frSB[r,c] = (sum(j in 0..3)(detX[r,4*c+j]) = 4) * 
               sum(j in 0..3)((dY[r,4*c+j]=2) - (dX[r,4*c+j]=2))
);


% A test
constraint forall(i in 0..15)(if i in [0,4,8,11,12,15] then gusK[5,i] = 1 else gusK[5,i] = 0 endif);




% % % ==================

% % array[4..6, 0..15] of var 0..2: dX;
% % array[4..5, 0..15] of var 0..2: dY;
% % array[4..5, 0..3] of var 0..2: pS;

% % array[0..15, 0..15] of int: DDT = array2d(0..15, 0..15, [16,0,0,0,......
% %                                                           0,0,0,2,......
% %                                                           0,0,0,2,......
% %                                                           0,0,2,0,......
% %                                                           ......]);

% % % Sbox
% % constraint forall(r in 4..5, c in [0,4,8,12])(
% %   pS[r,c] = DDT[sum(j in 0..3)(2^j * X[r,c+j]),
% %                 sum(j in 0..3)(2^j * Y[r,c+j])]
% % );
% % ......


% array[0..3] of var 0..1: A;
% array[0..3] of var 0..1: B;
% array[0..3] of var 0..1: C;

% % 1. table lookup
% array[0..1, 0..1] of int: XORt = array2d(0..1, 0..1,[0,1,1,0]);
                                        
% constraint forall(i in 0..1)(C[i] = XORt[A[i],B[i]]);
% constraint forall(i in 2..3)(XOR(A[i],B[i],C[i]));

% solve maximize (C[0] - C[3]);

% % 2. predicate
% predicate XOR(var 0..1: a, var 0..1: b, var 0..1: c) = 
%   c = (a + b) mod 2
% ;
