function [states,n_states]=therm_prop(fluidstr,instr1,in1,instr2,in2);
%  THERM_PROP Thermodynamic properties of fluids.
%
%  [STATES,N_STATES]=THERM_PROP('FLUIDSTR','INSTR1',IN1,'INSTR2',IN2) calculates the properties
%  of the thermodynamic state of a fluid determined by two independent state properties.
%
%  Input variables:
%     FLUIDSTR: string containing the symbol of the fluid.
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
%  Permitted fluid strings (the strings are case insensitive)
%     'r22'     : R22 (monochlorodifluoromethane)
%     'ammonia' : Ammonia (NH3)
%     'r134a'   : R134a (1,1,1,2-tetrafluoroethane)
%
%  Permitted state property strings and units (the strings are case insensitive):
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
% Original coding by Geert Van den Branden.
% Revision: 2.4		Date: June 20, 2008.
