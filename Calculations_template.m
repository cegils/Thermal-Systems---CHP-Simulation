
clear all
i = 1;  % select the measurement (i = 1..5) for which you want to evaluate the .m-file

% Measurement data
%-----------------
    % Fill out the data in vector form for all states (8). Start with
    % measurement 1, then add 2 ... until the 5th.
    % E.g.: p(x,y) = the pressure of the x-th state in the y-th measurement
    % E.g.: adding measurement 3 for the pressure of state 1 would look like:
    % p(1,:) = [p(1,1) p(1,2) p(1,3)];
    % indices
    
    % Pressures
        p(1,:)  =   [1.94109, 1.82156, 1.96219, 1.84969, 1.95516];  %9           % [bar relative]
        p(2,:)  =   [9.71412, 9.70314, 10.9886, 9.60426, 10.3843]; %2
        p(3,:)  =   [9.49439, 9.51637, 10.7908, 9.50538, 10.3513]; %3
        p(4,:)  =   [1.96922, 1.84969, 1.99031, 1.87078, 1.97625]; %8
        p(5,:)  =   [2.000 2.000 2.000 2.000 2.000]; %32
        p(6,:)  =   [2.000 2.000 2.000 2.000 2.000]; %33
        p(7,:)  =   [2.000 2.000 2.000 2.000 2.000]; %22
        p(8,:)  =   [2.000 2.000 2.000 2.000 2.000]; %23
        
    % Temperatures
        T(1,:)  =   [8.29375, 6.42957, 9.8666, 7.68902, 9.13519];  %9            % [°C]
        T(2,:)  =   [78.1044, 78.8187, 82.6768, 78.9982, 80.2611]; %2
        T(3,:)  =   [40.1518, 40.3196, 44.5008, 40.2415, 43.0901]; %3
        T(4,:)  =   [-0.07812, -1.22282, 0.12152, -1.22563, -0.39572]; %8
        T(5,:)  =   [29.6646, 30.32, 35.1364, 30.0974, 29.6781]; %32
        T(6,:)  =   [35.1507, 35.4704, 40.12, 35.3062, 36.8744]; %33
        T(7,:)  =   [13.8883, 12.1481, 14.0476, 13.8677, 14.14]; %22
        T(8,:)  =   [9.43357, 7.93335, 9.984, 7.86891, 9.77931]; %23
         
            
    % Flows
        Vwv     =      [2008.18, 2000.86, 1989.87, 1401.98, 1997.2];           	% [l/h]     volumetric water flow through vaporiser
        Vwc     =      [2008.18, 2010.01, 2015.51, 1993.53, 1401.98];
        Vf      =      [225.278, 192.525, 227.695, 201.534, 221.968];
        
    % Electric power compressor
       W       =      [4550.28, 4562.95, 4645.49, 4476.95, 4587.02];              	% [W] 

% Data conversion
%----------------
    % Pressures
        p   = 	(p+1.013)*100;       % [kPa absolute]
        
    % Temperatures
        T   =   T+273.15;            % [K]
            
    % Electric power compressor
    
        W   =   W/1000;             % [kW]
    
% Find the thermodynamic properties for all states
%-------------------------------------------------
     for j = 1:3
        [state(j),n_states(j)] = therm_prop('r134a','T',T(j,i),'p',p(j,i)); 
     end
     [state4,n_states(4)] = therm_prop('r134a','T',T(4,i),'h',state(3).h);
     state(4) = state4(1);
     for j = 5:8
         [state(j),n_states(j)] = prop_steam('T',T(j,i),'p',p(j,i));
     end
     
     for j = 1:8
        h(j) =  state(j).h;
        s(j) =  state(j).s;
     end
        
% Calculate mass 
%---------------------
% Hint: use state(j).rho with j = 3, 5, 7 for the needed densities

for i = 1:5
    mwv(i) =  Vwv(i) .* state(7).rho / (3600*1000);        % for evaporator side
    mwc(i) =  Vwc(i) .* state(5).rho / (3600*1000);        % for condensor side
    mf(i)  =  Vf(i) .* state(3).rho / (3600*1000);        % for freon
end

% Calculate COP (for water, freon and carnot)
%--------------

for i = 1:5
   COP_water(i) = mwc(i) * (h(6)-h(5))./ W(i);
   COP_freon(i) = (h(2)-h(3)) ./ (h(2)-h(1));
   COP_carnot(i) = T(5,i)/(T(5,i)-T(7,i)); % using temperatures 5 and 7
end 
% Determine energy flows (E(1), E(2), E(3)...E(8))
%-----------------------

for i = 1:5

E(1,i) = mf(i) .* h(1);
E(2,i) = mf(i) .* h(2);
E(3,i) = mf(i) .* h(3);
E(4,i) = mf(i) .* h(4);

E(5,i) = mwc(i) .* h(5);
E(6,i) = mwc(i) .* h(6);

E(7,i) = mwv(i) .* h(7);
E(8,i) = mwv(i) .* h(8);

end
%    
% % Energy balance
% % sum of energy in, sum of energy out, and energy loss (the diference between 1st two)
% %---------------
    % Vaporiser
    for i = 1:5
    
    EvapIn(i) = E(4,i) + E(7,i);
    EvapOut(i) = E(1,i) + E(8,i);
    EvapLos(i) = EvapIn(i) - EvapOut(i);
% 
%     % Compressor
    EcomIn(i) = E(1,i) + W(i);
    EcomOut(i) = E(2,i);
    EcomLos(i) = EcomIn(i)-EcomOut(i);
% 
%     % Condensor
    EconIn(i) = E(5,i) + E(2,i);
    EconOut(i) = E(3,i) + E(6,i);
    EconLos(i) = EconIn(i) - EconOut(i);
%     
%     % Expansion valve
    EexpIn(i) = E(3,i);
    EexpOut(i) = E(4,i);
    EexpLos(i) = EexpIn(i) - EexpOut(i);
%     

    end

% % Determine exergy flows
% %-----------------------
% %----uncomment the following once you have mf, mwv and mwc value
T0 = 273.15+20; % Reference temperature
p0 = 100; % Reference pressure
state0.f = therm_prop('r134a','T',T0,'p',p0); % Reference state freon
state0.w = prop_steam('T',T0,'p',p0); % Reference state water
B0.f = mf*(state0.f.h - T0*state0.f.s); % Reference exergy freon
B0.wv = mwv*(state0.w.h - T0*state0.w.s); % Reference exergy water evaporator
B0.wc = mwc*(state0.w.h - T0*state0.w.s); % Reference exergy water condensor
% 
% % Use this formula to calculate exergy (B(1),B(2)..B(8)) 
% %B(j) = mass*(h(j)-T0*s(j)) - B0.f 
% % For loop recommended

for j = 1:4
     
   for i = 1:5 
   B(j,i) = mf(i) .* (h(j)-T0*s(j)) - B0.f(i);  
   end
    
end

for j = 5:6
     
   for i = 1:5 
   B(j,i) = mwc(i) .* (h(j)-T0*s(j)) - B0.f(i);  
   end
    
end

for j = 7:8
     
   for i = 1:5 
   B(j,i) = mwv(i) .* (h(j)-T0*s(j)) - B0.f(i);  
   end
    
end

% % Exergy balance 
% % Sum of exergy in, sum of exergy out, and exergy loss (the diference between 1st two)
% % Just as you did for the energy balance calculation
% %---------------
    for i = 1:5
    
    BvapIn(i) = B(4,i) + B(7,i);
    BvapOut(i) = B(1,i) + B(8,i);
    BvapLos(i) = BvapIn(i) - BvapOut(i);
% 
%     % Compressor
    BcomIn(i) = B(1,i) + W(i);
    BcomOut(i) = B(2,i);
    BcomLos(i) = BcomIn(i)-BcomOut(i);
% 
%     % Condensor
    BconIn(i) = B(5,i) + B(2,i);
    BconOut(i) = B(3,i) + B(6,i);
    BconLos(i) = BconIn(i) - BconOut(i);
%     
%     % Expansion valve
    BexpIn(i) = B(3,i);
    BexpOut(i) = B(4,i);
    BexpLos(i) = BexpIn(i) - BexpOut(i);
%     

    end
