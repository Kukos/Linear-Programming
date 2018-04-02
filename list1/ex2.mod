/*
    Company has few items or (need few items) in cities
    Items has 2 Category:
    Normal,
    VIP,

    We need to balance items in cities (sent from City where has more than enough to City where item is needed)

    Cost is as follow:
    Distance for Normal
    Distance * 1.15 for VIP

    Please note that VIP item can replace Normal, but Normal cannot VIP


    Author: Michal Kukowski
    emial: michalkukowski10@gmail.com

    LICENCE GPL 3.0
*/


set City;
set Category;

param overflow{c in City, cat in Category};
param deficit{c in City, cat in Category};
param dist{src in City, dst in City};

var get_item{src in City, dst in City, cat in Category} >= 0;

s.t. sent_correctness {src in City, cat in Category} :
    sum{dst in City}(get_item[src, dst, cat]) = overflow[src, cat];

s.t. receive_correctness_VIP {dst in City} :
    sum {src in City}(get_item[src, dst, 'VIP']) >= deficit[dst, 'VIP'];

s.t. receive_correctness_Normal {dst in City} :
    sum {src in City, cat in Category}(get_item[src, dst, cat]) = deficit[dst, 'Normal'] + deficit[dst, 'VIP'];

minimize cost:
    sum {src in City, dst in City}(get_item[src, dst, 'Normal'] * dist[src, dst] + get_item[src, dst, 'VIP'] * dist[src, dst] * 1.15);

solve;

for {src in City, dst in City, cat in Category: get_item[src, dst, cat] > 0}
    printf "[%s] ----> [%s] %d %s items\n", src, dst, get_item[src, dst, cat], cat;

data;

set City := Warszawa Gdansk Szczecin Wroclaw Krakow Berlin Rostok Lipsk Praga Brno Bratyslawa Koszyce Budapeszt;
set Category := Normal VIP;

param dist :            Warszawa Gdansk Szczecin Wroclaw Krakow Berlin Rostok Lipsk  Praga  Brno   Bratyslawa Koszyce Budapeszt :=
			 Warszawa   0.0      283.86 454.30   301.38  252.27 517.76 629.47 602.75 517.65 458.81 532.59     391.50  545.33
			 Gdansk     283.86   0.0    287.52   377.03  485.39 402.86 426.95 538.50 555.69 591.01 698.81     652.84  763.46
			 Szczecin   454.30   287.52 0.0      308.85  527.30 127.08 177.57 275.65 373.34 492.41 614.57     703.19  732.41
			 Wroclaw    301.38   377.03 308.85   0.0     235.95 295.32 470.87 326.23 216.75 215.20 329.49     402.99  427.25
			 Krakow     252.27   485.39 527.30   235.95  0      427.25 698.69 552.12 393.41 259.54 297.02     177.81  293.30
			 Berlin     517.76   402.86 127.08   295.32  427.25 0.0    195.40 149.26 281.45 433.01 553.05     697.33  688.79
			 Rostok     629.47   426.95 177.57   470.87  698.69 195.40 0.0    306.98 474.85 627.50 748.11     872.19  880.78
			 Lipsk      602.75   538.50 275.65   326.23  552.12 149.26 306.98 0.0    202.45 384.20 491.97     698.88  644.51
			 Praga      517.65   555.69 373.34   216.75  393.41 281.45 474.85 202.45 0.0    184.45 289.59     516.77  442.88
			 Brno       458.81   591.01 492.41   215.20  259.54 433.01 627.50 384.20 184.45 0.0    122.20     344.32  260.94
			 Bratyslawa 532.59   698.81 614.57   329.49  297.02 553.05 748.11 491.97 289.59 122.20 0.0        313.15  161.54
			 Koszyce    391.50   652.84 703.19   402.99  177.81 697.33 872.19 698.88 516.77 344.32 313.15     0.0     438.13
			 Budapeszt  545.33   763.46 732.41   427.25  293.30 688.79 880.78 644.51 442.88 260.94 161.54     438.13  0.0;


param deficit :            Normal VIP :=
             Warszawa      0      4
             Gdansk        20     0
             Szczecin      0      0
             Wroclaw       8      0
             Krakow        0      8
             Berlin        16     4
             Rostok        2      0
             Lipsk         3      0
             Praga         0      4
             Brno          9      0
             Bratyslawa    4      0
             Koszyce       4      0
             Budapeszt     8      0;

param overflow :         Normal VIP :=
             Warszawa    14     0
             Gdansk      0      2
             Szczecin    12     4
             Wroclaw     0     10
             Krakow      10     0
             Berlin      0      0
             Rostok      0      4
             Lipsk       0     10
             Praga       10     0
             Brno        0      2
             Bratyslawa  0      8
             Koszyce     0      4
             Budapeszt   0      4;


end;
