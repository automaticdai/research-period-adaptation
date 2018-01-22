%% find optimal period
% control speficition: overshoot < 0.5, settling time < 1s
% based on the original model, max(period) = 18ms and 19ms
% select period to be 10ms

% current:  overshoot = 0.318, settling time = 0.85s 
% actual:   overshoot = 0.287, settling time = 0.54s 
pi_overshoot_sp = 0.5;
pi_settling_sp = 1;

gain_os = 1;
gain_st = 1;

T = S0.T;
T_i = 0.010;
itr = 0;
pi_overshoot_n = pi1(3, (abs(T - T_i) < 0.00001));
pi_settling_n = pi1(4, (abs(T - T_i) < 0.00001));
display(sprintf('Period:%.3f s, overshoot: %.3f, settling time: %.3f',...
                    T_i, pi_overshoot_n, pi_settling_n))
pi_overshoot_est = pi_overshoot_n;
pi_settling_est = pi_settling_n;

while true
    T_i = T_i + 0.001;
    itr = itr + 1;
    display('----------------------------------------')
    display(sprintf('--> iteration %d', itr))
    
    pi_overshoot = pi1(3, (abs(T - T_i) < 0.00001));
    pi_settling = pi1(4, (abs(T - T_i) < 0.00001));
    display(sprintf('> Period:%.3f s, overshoot: %.3f, settling time: %.3f',...
                    T_i, pi_overshoot, pi_settling))
    
    if (itr > 2)
    gain_os = gain_os + 2 * (pi_overshoot - pi_overshoot_est) / pi_overshoot_est;        
    gain_st = gain_st + 2 * (pi_settling - pi_settling_est) / pi_settling_est;          
    end
    
    pi_overshoot_est = pi_overshoot + gain_os * (pi_overshoot - pi_overshoot_n);
    pi_settling_est = pi_settling + gain_st * (pi_settling - pi_settling_n);
    
    pi_overshoot_est_nogain = pi_overshoot + 1 * (pi_overshoot - pi_overshoot_n);
    pi_settling_est_nogain = pi_settling + 1 * (pi_settling - pi_settling_n);
    
    subplot(2,1,1)
    scatter([itr], [pi_overshoot], 'bx')
    hold on;
    scatter([itr+1], [pi_overshoot_est], 'rx')
    scatter([itr+1], [pi_overshoot_est_nogain], 'gx')
    title('overshoot')
    axis([0 15 -inf +inf])
    
    subplot(2,1,2)
    scatter([itr], [pi_settling], 'bx')
    hold on;
    scatter([itr+1], [pi_settling_est], 'rx')
    scatter([itr+1], [pi_settling_est_nogain], 'gx')
    title('settling time')
    axis([0 15 -inf +inf])
    
    display(sprintf('> estimated overshoot: %.3f, settling time: %.3f',...
                    pi_overshoot_est, pi_settling_est))
                
    if ((pi_overshoot_est > pi_overshoot_sp) || (pi_settling_est > pi_settling_sp))
        break
    end
    
    pi_overshoot_n = pi_overshoot;
    pi_settling_n = pi_settling;
    input('Press to connitue...')
end

% new period: 20ms
% overshoot: 0.467, settling time 0.79s