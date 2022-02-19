# Calculating_Motion_Trajectory


Motion of point is described by equation: x1' = x2 + x1(0,9 - x12 - x22)x2' = -x1 + x2(0,9 - x12 - x22)\
Calculate trajectory of motion on interval [0, 20] for following initial conditions: \
(a) x1(0)=10 x2(0)=9;\
(b) x1(0)=0 x2(0)=7;\
(c) x1(0)=7 x2(0)=0;\
(d) x1(0)=0.001 x2(0)=0.001.


Methods implemented and compared to solving this problem:
1. Runge-Kutta of the fourth order (RK4) with a constant step;
2. Multistep predictor-corrector Adams fourth order with a constant step;
3. Rungego-Kutty fourth order (RK4) with a variable step;

