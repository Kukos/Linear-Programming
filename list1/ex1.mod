/*
    Program to check solver power using hilbert matrix

    Author: Michal Kukowski
    email: michalkukowski10@gmail.com

    LICENCE GPL 3.0
*/

param n >= 0;

set ROW := 1..n;
set COL := 1..n;

param matrix{i in ROW, j in COL} := 1 / (i + j - 1);
param b{i in ROW} := sum {j in COL} (1 / (i + j - 1));
param c{i in ROW} := sum {j in COL} (1 / (i + j - 1));
param correct_x{i in ROW} := 1;

var x{i in ROW} >= 0;

s.t. matrix_formula {i in ROW} :
    b[i] = sum{j in COL} (matrix[i, j] * x[j]);

minimize x_cond {i in ROW}: x[i] * c[i];

solve;

printf{i in ROW} "X[%d] = %g\tCorrect = %g\n", i, x[i], correct_x[i];
printf "ERROR = %g\n", (sum{i in ROW}(sqrt((correct_x[i] - x[i]) * (correct_x[i] - x[i])))) / (sum{i in ROW}(sqrt((correct_x[i]) * (correct_x[i]))));

data;

param n := 7;

end;
