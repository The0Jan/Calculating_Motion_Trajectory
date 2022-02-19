
%==========================================================================
% Przedział
range = [0 20];
% Warunki początkowe
% A
x_0a = [8 7];
% B
x_0b = [0 0.4];
% C
x_0c = [5 0];
% D
x_0d = [0.01 0.001];
% Łącznie
x_0 = [x_0a; x_0b; x_0c; x_0d];
%==========================================================================
% Etap testowania

% Testowanie dla metody Rungego-Kutty 
%        Krok:
%        Zbyt duży| Idealny
step_test = [ 0.02, 0.01;
              0.8, 0.01;
              0.09, 0.01;
              0.8, 0.01;];

type = ['A', 'B', 'C', 'D'];

% Która metoda ma zostać testowana 
rk44 = 1;
adamus = 1;
rk4dynamo = 1;


% Zmienne do liczenia czasu
times = zeros(1,4);
avg_times = zeros(1,3);

% Zmiene do liczenia błędu
avg_error = zeros(1,3);
max_error = zeros(1,3);
if (rk44 == 1)
for i=1:4
    [t_ode,x_ode] = ode45(@both,range,x_0(i,:));

    tic 
    [t1, x1, r1 ] = perform_rk4(step_test(i,1), x_0(i,:), range);
    times(i) =  toc;

    [t2, x2, r2 ] = perform_rk4(step_test(i,2), x_0(i,:), range);

    title_e = strcat('RK4(Error)-',type(i));
    title = strcat('RK4-', type(i));
    file_n = "RK4_"+ type(i) + ".png";
    file_e = "RK4_E_"+ type(i) + ".png";
    draw_graph(title_e,file_e, ["Time", "Error"] ,[ "h="+step_test(i,1), "h="+step_test(i,2) ],["-","-"], t1',r1, t2', r2);
    draw_graph(title,file_n, ["X1", "X2"], ["h="+step_test(i,1), "h="+step_test(i,2),  "ode45" ],["-.","-.","-"], x1(:,1),x1(:,2), x2(:,1), x2(:,2), x_ode(:,1), x_ode(:,2) );
    
    max_error(1) = max([max(r2), max_error(1)]);
    avg_error(1) = avg_error(1) + sum(r2)/length(r2);
end
end

% Liczenie czasu dla rk4
avg_times(1) = sum(times)/length(times);

% Testowanie dla perydktor-korektor Adamsa
%        Krok:
%        Zbyt duży| Idealny
step_test = [ 0.02, 0.01;
               0.6, 0.01;
              0.08, 0.01;
               0.6, 0.01;];

if (adamus == 1)
for i=1:4
    [t_ode,x_ode] = ode45(@both,range,x_0(i,:));

    tic
    [t1, x1, r1 ] = perform_adams(step_test(i,1), x_0(i,:), range);
    times(i) =  toc;

    [t2, x2, r2 ] = perform_adams(step_test(i,2), x_0(i,:), range);

    title_e = strcat('PEKE Adamsa(Error)-',type(i));
    title = strcat('PEKE Adamsa- ', type(i));
    file_n = "ADAMS"+ type(i) + ".png";
    file_e = "ADAMS_E_"+ type(i) + ".png";
    draw_graph_adams(title_e,file_e, ["Time", "Error"] ,[ "h="+step_test(i,1), "h="+step_test(i,2) ],["-","-"], t1',r1, t2', r2);
    draw_graph(title, file_n,["X1", "X2"], ["h="+step_test(i,1), "h="+step_test(i,2),  "ode45" ],["-.","-.","-"], x1(:,1),x1(:,2), x2(:,1), x2(:,2), x_ode(:,1), x_ode(:,2) );

    max_error(2) = max([max(r1), max_error(2)]);
    avg_error(2) = avg_error(2) + sum(r1)/length(r1);
end
end
avg_times(2) = sum(times)/length(times);


if (rk4dynamo == 1)
for i=1:4
    [t_ode,x_ode] = ode45(@both,range,x_0(i,:));
    tic
    [t1, x1, r1 ] = perform_rk4dynamic(0.05, x_0(i,:), range, 2^-16, 2^-16);
    times(i) =  toc;

    title_e = strcat('RK4 dynamic step(Error)-',type(i));
    title = strcat('RK4 dynamic step-', type(i));
    file_n = "RKD"+ type(i) + ".png";
    file_e = "RKD_E_"+ type(i) + ".png";
    draw_graph_adams(title_e,file_e, ["Time", "Error"] ,[ "h=0.05" ],["-"], t1',r1);
    draw_graph(title,file_n, ["X1", "X2"], ["h=0.05"  "ode45" ],["-","-."], x1(:,1),x1(:,2), x_ode(:,1), x_ode(:,2) );

    max_error(3) = max([max(r1), max_error(3)]);
    avg_error(3) = avg_error(3) + sum(r1)/length(r1);
end
end
avg_times(3) = sum(times)/length(times);


avg_error = avg_error/4;
methods = ["RK4", "PEKE Adams", "RK4 ze zmiennym krokiem"];
for i=1:3
    disp("--------------------------------")
    disp(methods(i));
    disp("Max error     :" + max_error(i));
    disp("Average error :" + avg_error(i));
    disp("Average time  :" + avg_times(i));
end
%==========================================================================
% Rysowanie grafów
function draw_graph(ftitle, file_name, labels, legends, style, varargin )
    figure, hold on
    for i = 1:2:length(varargin)
        index = fix((i+1)/2);
        plot(varargin{i},varargin{i+1},style(index));
        Legend{index} = legends(index);
    end
    hold off
    grid on
    legend(Legend)
    title(ftitle, "FontSize", 18);
    xlabel(labels(1), "FontSize", 16);
    ylabel(labels(2), "FontSize", 16);
    saveas(gcf, file_name)
end

function draw_graph_adams(ftitle,file_name, labels, legends, style, varargin )
    figure
    for i = 1:2:length(varargin)
        index = fix((i+1)/2);

        semilogy(varargin{i},varargin{i+1});
        Legend{index} = legends(index);
        hold on;
    end
    hold off
    grid on
    legend(Legend)
    title(ftitle, "FontSize", 18);
    xlabel(labels(1), "FontSize", 16);
    ylabel(labels(2), "FontSize", 16);
    saveas(gcf, file_name)
end


% Algorytmy
% =========================================================================


% Metoda Rungego Kutty 4 rzędu ze zmiennym krokiem
function [t, x, errors] = perform_rk4dynamic(hn, x_0, range, e_w, e_b)
    t_now = range(1);
    index = 1;
    t(index) = t_now;
    h = hn;
    x(index,:) = x_0;
    errors = zeros(1,1);
    while t_now < range(2)

        % Liczenie (x)n+1
        [x21, x22] =  rk4(h, x(index, 1), x(index, 2));
        x(index + 1, :) = [x21 x22];

        % Błąd aproksymacji
        % Liczenie podwójnego kroku hn/2
        [x1_1hn, x2_1hn] = rk4(h/2, x(index, 1), x(index, 2));
        [x11, x12] = rk4(h/2, x1_1hn, x2_1hn);
        x_half2 = [x11, x12];

        error = (x_half2 - x(index + 1, :))*16/(2^4-1);
        errors(index+1) = norm(error);

        % Korekcja kroku
        e_half = abs(x_half2);
        e = e_half*e_w + e_b ;
        mini = e(:)./abs(error(:));
        alfa = min(mini)^(1/5);
      
        % liczenie hn*
        Hnew = 0.9 * alfa * h;
        if alfa * 0.9 >= 1
            t_now = t_now + h;
            h = min([Hnew, 5*h, range(2)-t_now]);
            t(index + 1) = t_now;
            index = index + 1;
        else
            assert(Hnew > realmin ) ;
            h = Hnew;
        end
    end
end

% Predyktor-korektor Adamsa 4 rzędu
function [t, x, errors] = perform_adams(hn, x_0, range)
    t_now = range(1);
    t(1) = t_now;
    x(1,:) = x_0;
    errors(1) = zeros(1, 1);
    for i=1:3
        [x21 x22] =  rk4(hn, x(i, 1), x(i, 2));
        x(i + 1, :) = [x21 x22];
        % Liczenie błędu aproksymacji
        [x1_1hn, x2_1hn] = rk4(hn/2, x(i, 1), x(i, 2));
        x_half2 = rk4(hn/2, x1_1hn, x2_1hn);

        error = norm((x_half2 - x(i+1, :))*16/15);
        errors(i+1) = error;

        % Przesunięcie w t
        t_now = t_now + hn;
        t(i + 1) = t_now;
    end
    index = 5;
    while t_now < range(2)
        % P
        % yn(0) = yn-1 + h(E bjfn-j)
        x(index, 1) = x(index-1, 1) + hn*( 55/24*x1p(x(index-1,1), x(index-1,2)) + (-59/24)*x1p(x(index-2,1), x(index-2,2)) + 37/24*x1p(x(index-3,1), x(index-3,2)) + (-9/24)*x1p(x(index-4,1), x(index-4,2)));
        x(index, 2) = x(index-1, 2) + hn*( 55/24*x2p(x(index-1,1), x(index-1,2)) + (-59/24)*x2p(x(index-2,1), x(index-2,2)) + 37/24*x2p(x(index-3,1), x(index-3,2)) + (-9/24)*x2p(x(index-4,1), x(index-4,2)));


        % Częściowa estymacja błędu aproksymacji
        x_pred = x(index, :);

        % E
        fn1 = x1p(x(index,1), x(index,2));
        fn2 = x2p(x(index,1), x(index,2));

        % K
        x(index, 1) = x(index-1, 1) + 9/24*hn*fn1 + hn*( 19/24*x1p(x(index-1,1), x(index-1,2)) + (-5/24)*x1p(x(index-2,1), x(index-2,2)) + 1/24*x1p(x(index-3,1), x(index-3,2))) ;
        x(index, 2) = x(index-1, 2) + 9/24*hn*fn2 + hn*( 19/24*x2p(x(index-1,1), x(index-1,2)) + (-5/24)*x2p(x(index-2,1), x(index-2,2)) + 1/24*x2p(x(index-3,1), x(index-3,2))) ;


        % Aproksymacja błędu
        errors(index) = norm(-19/270*(x_pred - x(index, :)));

        t_now = t_now + hn;
        t(index) = t_now;
        index = index + 1;
    end
end

% Metoda Rungego Kutty 4 rzędu
function [t, x, errors] = perform_rk4(hn, x_0, range)
    t_now = range(1);
    index = 1;
    t(index) = t_now;
    x(index,:) = x_0;
    errors = zeros(1,1);
    while t_now <= range(2)

        % Liczenie (x)n+1
        [x21 x22] =  rk4(hn, x(index, 1), x(index, 2));
        x(index + 1, :) = [x21 x22];

        % Błąd aproksymacji
        % Liczenie podwójnego kroku hn/2
        [x1_1hn, x2_1hn] = rk4(hn/2, x(index, 1), x(index, 2));
        x_half2 = rk4(hn/2, x1_1hn, x2_1hn);

        error = norm((x_half2 - x(index+1, :))*16/15);
        errors(index+1) = error;

        % Przesunięcie w t
        t_now = t_now + hn;
        t(index + 1) = t_now;

        index = index + 1;
    end
end


function [x21, x22] = rk4(hn, x_11, x_12)
    % Liczenie k1
    k_11 = x1p(x_11, x_12);
    k_12 = x2p(x_11, x_12);

    % Liczenie k2
    k_21 = x1p(x_11 + hn*k_11/2, x_12 + hn*k_12/2);
    k_22 = x2p(x_11 + hn*k_11/2, x_12 + hn*k_12/2);

    % Liczenie k3
    k_31 = x1p(x_11 + hn*k_21/2, x_12 + hn*k_22/2);
    k_32 = x2p(x_11 + hn*k_21/2, x_12 + hn*k_22/2);

    % Liczenie k4
    k_41 = x1p(x_11 + hn*k_31, x_12 + hn*k_32);
    k_42 = x2p(x_11 + hn*k_31, x_12 + hn*k_32);

    % Liczenie (x1)n+1 i (x2)n+1
    x21 = x_11 + hn*(k_11 + 2*k_21 + 2*k_31 + k_41)/6;
    x22 = x_12 + hn*(k_12 + 2*k_22 + 2*k_32 + k_42)/6;
end

function out = x2p(x1, x2)
    out = -x1 + x2*(0.2 - x1^2 -x2^2);
end

function out = x1p(x1, x2)
    out = x2 + x1*(0.2 - x1^2 - x2^2);
end

function dydt = both(t,x)
    dydt = [x1p(x(1), x(2)); x2p(x(1), x(2))];
end



