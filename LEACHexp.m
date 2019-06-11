clc, clear all, close all

t = [];
t_bleach_desc = [];

t_bleach_high = [];
t_bleach_low = [];
t_bleach_zero = [];

p = 0.05;
f = 0.7;
episode = 1/p;
rnd = 0;

leach_ones = ones(9);
leach_zeros = zeros(9);
SoC = 1:-p:p;
SoC_high = 0.9:-0.01:0.9-0.01*(episode-0.01);  
SoC_low = 0.3:-0.01: 0.3-0.01*(episode-0.01);  

for i = 1:episode
    t = [t, (p / (1 - p * mod(rnd, episode)))];
    
    t_bleach_desc = [t_bleach_desc, 2*(1 - f)*(p / (1 - p * mod(rnd, episode))) * SoC(i) + (1 / (1 - (1 - f) * (p / (1 - p * mod(rnd, episode))))) * f * (p / (1 - p * mod(rnd, episode)))];
    %*(rnd/(1+mod(rnd, episode)))
    %(exp(1)/exp((episode-1)/mod(rnd, episode)))
    t_bleach_high = [t_bleach_high, 2*(1 - f) * (p / (1 - p * mod(rnd, episode))) * SoC_high(i) + (1 / (1 - (1 - f) * (p / (1 - p * mod(rnd, episode))))) * f * (p / (1 - p * mod(rnd, episode)))];
    t_bleach_low = [t_bleach_low, 2*(1 - f) * (p / (1 - p * mod(rnd, episode))) * SoC_low(i) + (1 / (1 - (1 - f) * (p / (1 - p * mod(rnd, episode))))) * f * (p / (1 - p * mod(rnd, episode)))];
    t_bleach_zero = [t_bleach_zero, 2*(1 - f) * (p / (1 - p * mod(rnd, episode))) * leach_zeros(i) + (1 / (1 - (1 - f) * (p / (1 - p * mod(rnd, episode))))) * f * (p / (1 - p * mod(rnd, episode)))];
    
    rnd = rnd+1;
end


rndVec = 0:length(t)-1;


threeD = 0;


figure(1)
if threeD == 0
    h1 = plot(rndVec, t, 'color', 'r');
    hold on
    h2 = plot(rndVec, t_bleach_desc, 'color', 'b' );
    h3 = plot(rndVec, t_bleach_high, 'color', 'g');
    h4 = plot(rndVec, t_bleach_low, 'color', 'k');
    h5 = plot(rndVec, t_bleach_zero, 'color', 'y');
    legend([h1(1) h2(1) h3(1) h4(1) h5(1)], 'LEACH','BLEACH_{DESC}','BLEACH_{HIGH}','BLEACH_{LOW}', 'BLEACH_{ZERO}')
    ylim([0 1])
    xlim([0 (episode-1)])
    xlabel('Rounds')
    ylabel('T(rnd, SoC)')
elseif threeD == 1
    h1 = plot3(rndVec, leach_ones, t, 'color', 'r');
    hold on
    h2 = plot3(rndVec, SoC, t_bleach_desc, 'color', 'b' );
    h3 = plot3(rndVec, SoC_high, t_bleach_high, 'color', 'g');
    h4 = plot3(rndVec, SoC_low, t_bleach_low, 'color', 'k');
    xlabel('Rounds')
    ylabel('SoC')
    zlabel('T(rnd, SoC)')
    ylim([0 1])
    xlim([0 (episode-1)])
    title('Regular LEACH vs BLEACH')
    legend([h1(1) h2(1) h3(1) h4(1)], 'LEACH','BLEACH','BLEACH_{HIGH}','BLEACH_{LOW}')
else
    h1 = plot(rndVec, t, 'color', 'r');
    legend([h1(1)], 'LEACH')
    ylim([0 1])
    xlim([0 (episode-1)])
    xlabel('Rounds')
    ylabel('T(rnd)')
    
    figure(2)
    h2 = plot(rndVec, t_bleach_desc, 'color', 'b' );
    legend([h2(1)], 'BLEACH')
    ylim([0 1])
    xlim([0 (episode-1)])
    xlabel('Rounds')
    ylabel('T(rnd, SoC)')
    
    figure(3)
    h3 = plot(rndVec, t_bleach_high, 'color', 'g');
    legend([h3(1)], 'BLEACH_{HIGH}')
    ylim([0 1])
    xlim([0 (episode-1)])
    xlabel('Rounds')
    ylabel('T(rnd, SoC)')
    
    figure(4)
    h4 = plot(rndVec, t_bleach_low, 'color', 'k');
    legend([h4(1)],'BLEACH_{LOW}')
    ylim([0 1])
    xlim([0 (episode-1)])
    xlabel('Rounds')
    ylabel('T(rnd, SoC)')
end




