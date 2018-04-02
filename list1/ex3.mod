/*
    EX3 from List, a little complicated to explain ex description, please see list description

    Author: Michal Kukowski
    email: michalkukowski10@gmail.com

    LICENCE GPL3.0

*/

set Product;
set Mats;

param price{p in Product};

param mats_min_order{m in Mats};
param mats_max_order{m in Mats};

param mats_cost_order{m in Mats};

param mats_waste{m in Mats, p in Product};
param mats_waste_destroy_cost{m in Mats, p in Product};

param ingr_min_mats{m in Mats, p in Product};
param ingr_max_mats{m in Mats, p in Product};

var get_mats{m in Mats, p in Product} >= 0.0;
var get_waste{m in Mats, p in Product} >= 0.0;

/* order */
s.t. min_order {m in Mats} :
    sum{p in Product}(get_mats[m, p]) >= mats_min_order[m];

s.t. max_order {m in Mats} :
    sum{p in Product}(get_mats[m, p]) <= mats_max_order[m];

/* waste using */
s.t. waste_using_A {m in Mats} :
    get_waste[m, 'A'] = 0;

s.t. waste_using_B {m in Mats} :
    get_waste[m, 'B'] = 0;

/* waste using and production */
s.t. waste_using_C{m in Mats} :
    get_waste[m, 'C'] <= get_mats[m, 'A'] * mats_waste[m, 'A'];

s.t. waste_using_D{m in Mats} :
    get_waste[m, 'D'] <= get_mats[m, 'B'] * mats_waste[m, 'B'];

/* production specification */
s.t. min_ingr{m in Mats, p in Product} :
    get_mats[m, p] >= sum{mm in Mats}(get_mats[mm, p] + get_waste[mm, p]) * ingr_min_mats[m, p];

s.t. max_ingr{m in Mats, p in Product} :
    get_mats[m, p] <= sum{mm in Mats}(get_mats[mm, p] + get_waste[mm, p]) * ingr_max_mats[m, p];

maximize INCOME :
       sum{p in Product, m in Mats}((get_mats[m, p] * (1.0 - mats_waste[m, p]) + get_waste[m, p]) * price[p]) /* income from selling */
      -sum{p in Product, m in Mats}(get_mats[m, p] * mats_cost_order[m]) /* order cost */
      -sum{m in Mats}((get_mats[m, 'A'] * mats_waste[m, 'A'] - get_waste[m, 'C']) * mats_waste_destroy_cost[m, 'A']) /* cost for destroying wastes from A */
      -sum{m in Mats}((get_mats[m, 'B'] * mats_waste[m, 'B'] - get_waste[m, 'D']) * mats_waste_destroy_cost[m, 'B']); /* cost for destroying wastes from B */


solve;

printf "\nMATS\n\n";
for {m in Mats, p in Product: get_mats[m ,p] > 0.0}
    printf"Mats [%s] for Product [%s] %g mats\n", m, p, get_mats[m, p];

printf "\nWASTES\n\n";
for {m in Mats, p in Product: get_waste[m ,p] > 0.0}
    printf"Wastes [%s] for Product [%s] %g wastes\n", m, p, get_waste[m, p];
printf "\n";

printf "DESTROY\n\n";
for {m in Mats: (get_mats[m, 'A'] * mats_waste[m, 'A'] - get_waste[m, 'C']) > 0.0}
    printf  "Destroy from [%s A] %g wastes\n", m, (get_mats[m, 'A'] * mats_waste[m, 'A'] - get_waste[m, 'C']);

for {m in Mats: (get_mats[m, 'B'] * mats_waste[m, 'B'] - get_waste[m, 'D']) > 0.0}
    printf  "Destroy from [%s B] %g wastes\n", m, (get_mats[m, 'B'] * mats_waste[m, 'B'] - get_waste[m, 'D']);

printf "\n";

data;

set Product := A B C D;
set Mats := M1 M2 M3;

param price :=
                A 3.0
                B 2.5
                C 0.6
                D 0.5;

param mats_min_order :=
                        M1 2000.0
                        M2 3000.0
                        M3 4000.0;

param mats_max_order :=
                        M1 6000.0
                        M2 5000.0
                        M3 7000.0;

param mats_cost_order :=
                        M1 2.1
                        M2 1.6
                        M3 1.0;

param mats_waste :       A    B    C    D   :=
                    M1   0.1  0.2  0.0  0.0
                    M2   0.2  0.2  0.0  0.0
                    M3   0.4  0.5  0.0  0.0;

param mats_waste_destroy_cost :       A    B     C    D     :=
                                 M1   0.1  0.05  0.0  0.0
                                 M2   0.1  0.05  0.0  0.0
                                 M3   0.2  0.4   0.0  0.0;

param ingr_min_mats :       A   B   C   D   :=
                        M1  0.2 0.1 0.2 0.0
                        M2  0.4 0.0 0.0 0.3
                        M3  0.0 0.0 0.0 0.0;

param ingr_max_mats :       A   B   C   D   :=
                        M1  1.0 1.0 0.2 0.0
                        M2  1.0 1.0 0.0 0.3
                        M3  0.1 0.3 0.0 0.0;

end;
