function sttngs = lpisettings(type,derivative_strictness,simplify,solver)
arguments
    type {mustBeMember(type,{'light','heavy','veryheavy','stripped','extreme','custom'})}='light';
    derivative_strictness {mustBeNonnegative}= 0;
    simplify {mustBeMember(simplify,{'','psimplify'})}= '';
    solver {mustBeMember(solver,{'sedumi','mosek','sdpnalplus','sdpt3'})} = 'sedumi';
end

switch type
    % Set the general LPI settings for 1D case, adding 2D settings as a
    % separate field.
    case 'light'
        sttngs = settings_PIETOOLS_light;
        sttngs.settings_2d = settings_PIETOOLS_light_2D;
    case 'custom'
        sttngs = settings_PIETOOLS_custom;
        sttngs.settings_2d = settings_PIETOOLS_custom_2D;
    case 'extreme'
        sttngs = settings_PIETOOLS_extreme;
        sttngs.settings_2d = settings_PIETOOLS_extreme_2D;
    case 'heavy'
        sttngs = settings_PIETOOLS_heavy;
        sttngs.settings_2d = settings_PIETOOLS_heavy_2D;
    case 'stripped'
        sttngs = settings_PIETOOLS_stripped;
        sttngs.settings_2d = settings_PIETOOLS_stripped_2D;
    case 'veryheavy'
        sttngs = settings_PIETOOLS_veryheavy;
        sttngs.settings_2d = settings_PIETOOLS_veryheavy_2D;
    otherwise
        warning('Unknown settings parameter requested. Defaulting to light settings');
        sttngs = settings_PIETOOLS_light;
        sttngs.settings_2d = settings_PIETOOLS_light_2D;
end

% Set strictness of positivity of LF and negativity of its derivative.
sttngs.eppos = 1e-4;      % Positivity of Lyapunov Function with respect to real-valued states
sttngs.eppos2 = 1*1e-6;   % Positivity of Lyapunov Function with respect to spatially distributed states
sttngs.epneg = derivative_strictness;    % Negativity of Derivative of Lyapunov Function in both ODE and PDE state

% Set same settings for 2D case.
sttngs.settings_2d.eppos = [1e-4; 1e-6; 1e-6; 1e-6];    % Positivity of LF wrt R x L2[s1] x L2[s2] x L2[s1,s2]
sttngs.settings_2d.epneg = derivative_strictness;       % Negativity of Derivative of Lyapunov Function in both ODE and PDE state


% Set the SOS solve settings (independent of dimension).
sttngs.sos_opts.simplify = strcmp(simplify,'psimplify');    % Use psimplify in solving the SOS?
sttngs.sos_opts.solver = solver;    % Use psimplify in solving the SOS?
sttngs = class(sttngs,'lpisettings');
end