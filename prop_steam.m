function [states,n_states]=prop_steam(instr1,in1,instr2,in2)
%
% PROP_STEAM Thermodynamic properties of water and steam.
%  [STATES,N_STATES]=PROP_STEAM('INSTR1',IN1,'INSTR2',IN2) calculates the properties
%  of the thermodynamic state of steam or water determined by two independent
%  state properties.
%
%  Input variables:
%     INSTR1, INSTR2: strings containing the symbols of the two input state properties.
%     IN1, IN2: values of the two input state properties.
%
%  Output variables:
%     STATES: (a vector of) a structure containing the thermodynamic properties of the requested state. The fields
%     of the structure are the permitted strings for 'INSTR1' and 'INSTR2' and three extra fields:
%        name : the name of the state (is empty, but can be supplied afterwards by the user);
%        fluid: the name of the fluid, i.e. h2o;
%        msg  : additional information about the state.
%     For the vapour fraction field x, the following arbitary values are attributed to the one-phase states.
%        -Inf : for one-phase fluid states below the critical temperature,
%        +Inf : for one-phase vapour states below the critical temperature,
%         NaN : for one-phase states above the critical temperature.
%
%     N_STATES: the number of different thermodynamic states that correspond with the input values. There are
%     five different possibilities for the number of thermodynamic states:
%        0  : no thermodynamic states corresponding with the input state properties exist. In this case the
%             output-variable STATES is empty.
%        1  : one single thermodynamic states corresponds with the input state properties. STATES is a single
%             structured variable.
%        2  : two  thermodynamic states corresponds with the input state properties. STATES is a vector of two
%             structured variables.
%        3  : three thermodynamic states corresponds with the input state properties. STATES is a vector of three
%             structured variables. This is the maximum number of independent output thermodynamic states.
%        Inf: an infinite number of states which correspond with the input state properties, exist. This is the case
%             when the two input state properties are not independent of eachother in the two-phase region: T-p, T-g
%             and p-g. In this case the output-variable STATES is a vector of two structured variables. The first one
%             is the state of the saturated liquid corresponding with the input state properties, the second is the
%             state of the saturated vapour. All two-phase states in between the saturated liquid and vapour are states
%             which correspond with the input state properties.
%
%  Permitted strings and units (the strings are case insensitive):
%     'p': pressure [kPa]
%     't': temperature [K]
%     'v': specific volume [m^3/kg]
%     'rho': density [kg/m^3]
%     'u': specific internal energy [kJ/kg]
%     'h': specific energy [kJ/kg]
%     's': specific entropy [kJ/kg/K]
%     'f': specific Helmholtz free energy [kJ/kg]
%     'g': specific Gibbs free energy [kJ/kg]
%     'x': vapour fraction [-]
%
%  Range of validity:
%     [273.15K <= T <= 1073.15K ; 0.1kPa <= p <= 100000kPa]
%     [1073.15K <= T <= 2273.15K ; 0.1kPa <= p <= 10000kPa]
%
%  Reference state:
%     The specific internal energy and the specific entropy of the saturated liquid at the triple point
%     are equal to zero. The temperature and pressure of the triple point are: 273.16K and 611.657kPa.
%
%  Examples:
%
%     1. [states,n_states]=prop_steam('p',150,'s',7.5)
%
%        states =
%
%           name: []
%          fluid: 'h2o'
%              T: 4.4012e+002
%              p: 150
%              v: 1.3399e+000
%            rho: 7.4633e-001
%              u: 2.6061e+003
%              h: 2.8071e+003
%              s: 7.5000e+000
%              f: -6.9481e+002
%              g: -4.9383e+002
%              x: Inf
%            msg: 'single-phase vapour'
%
%        n_states =
%
%             1
%							
%        There is one thermodynamic state (n_states = 1) with a pressure of 150kPa and a specific entropy
%        of 7.5kJ/kg/K. This state is a single-phase vapour state as the msg-field indicates. The vapour fraction
%        is arbitrairly set to Inf.  
%		
%     2. [states,n_states]=prop_steam('T',300,'h',200)
%
%        states(1) =                            states(2) =
%
%           name: []                               name: []
%          fluid: 'h2o'                           fluid: 'h2o'
%              T: 300                                 T: 300
%              p: 3.5366e+000                         p: 9.8307e+004
%              v: 1.4028e+000                         v: 9.6472e-004
%            rho: 7.1285e-001                       rho: 1.0366e+003
%              u: 1.9504e+002                         u: 1.0516e+002
%              h: 200                                 h: 2.0000e+002
%              s: 6.8454e-001                         s: 3.6235e-001
%              f: -1.0323e+001                        f: -3.5455e+000
%              g: -5.3621e+000                        g: 9.1294e+001
%              x: 3.5869e-002                         x: -Inf
%            msg: 'two-phase state'                 msg: 'single-phase liquid'
%
%        n_states =
%
%             2
%
%        There are two different thermodynamic states with a temperature of 300K and a specific enthalpy
%        of 200kJ/kg.
%
%     3. [states,n_states]=prop_steam('T',700,'x',.95)
%
%        states =
%
%             []
%
%        n_states =
%			
%             0
%
%        The temperature T is above the critical temperature, consequently there is no two-phase state with a
%        vapour fraction x .
%        Check the input values of temperature [K] or change the vapour fraction x for another state property.
%
%     4. [states,n_states]=prop_steam('T',425,'g',-150.5692)
%
%        states(1) =                            states(2) = 
%
%           name: []                               name: []
%          fluid: 'h2o'                           fluid: 'h2o'
%              T: 425                                 T: 425
%              p: 5.0018e+002                         p: 5.0018e+002
%              v: 1.0926e-003                         v: 3.7468e-001
%            rho: 9.1527e+002                       rho: 2.6690e+000
%              u: 6.3970e+002                         u: 2.5607e+003
%              h: 6.4024e+002                         h: 2.7481e+003
%              s: 1.8607e+000                         s: 6.8205e+000
%              f: -1.5112e+002                        f: -3.3798e+002
%              g: -1.5057e+002                        g: -1.5057e+002
%              x: 0                                   x: 1
%            msg: 'saturated liquid'                msg: 'saturated vapour'
%
%        n_states =
%
%           Inf
%
%  Errors:
%		Dependant states:
% 		Out of range:
%
%  References:
%     The state properties are calculated by means of the 1997 release on the Industrial Formulation
%     for the Thermodynamic Properties of Water and Steam by the International Association for the
%     Properties of Water and Steam (IAPWS). More information about the IAPWS or on the 1997 release can
%     be found at www.iapws.org .
%
% Original coding by Geert Van den Branden.
% Copyright (c) by Geert Van den Branden.
% Revision: 2.8		Date: August 9, 2010.
