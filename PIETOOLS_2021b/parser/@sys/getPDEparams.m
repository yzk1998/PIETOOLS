function out = getPDEparams(pdeObj)
equations = pdeObj.equation;
statelist = pdeObj.states;
eqnNum = length(equations);
odeeqns = {}; pdeeqns = {}; outeqns = {}; bceqns = {};
for i=1:eqnNum
    eqnType{i} = identifyEqnType(equations{i});
    if strcmp(eqnType{i},'ode')
        odeeqns{end+1} = equations{i};
    elseif strcmp(eqnType{i},'pde')
        pdeeqns{end+1} = equations{i};
    elseif strcmp(eqnType{i},'out')
        outeqns{end+1} = equations{i};
    elseif strcmp(eqnType{i},'bc')
        bceqns{end+1} = equations{i};
    end
end
out = pdeparams();


% find the dimensions of the various signals
out.n.nu = sum(statelist.veclength(find(pdeObj.ControlledInputs)));
out.n.nw = sum(statelist.veclength(find((~pdeObj.ControlledInputs)&strcmp(statelist.type,'in'))));
out.n.ny = sum(statelist.veclength(find(pdeObj.ObservedOutputs)));
out.n.nz = sum(statelist.veclength(find((~pdeObj.ObservedOutputs)&strcmp(statelist.type,'out'))));
out.n.nx = sum(statelist.veclength(strcmp(statelist.type,'ode')));
npde_sum = sum(statelist.veclength(strcmp(statelist.type,'pde')));

% finding nr, nv
for i=1:eqnNum
    statevec = equations{i}.statevec;
    if strcmp(eqnType{i},'pde')||strcmp(eqnType{i},'bc') % find nv terms
        if any(ismember({'ode','in'},statevec.state.type))
            eqnlen = sum(equations{i}.operator.dim(:,1));
            out.n.nv = out.n.nv+eqnlen;
        end
    else % find nr terms
        if ismember('pde',statevec.state.type)
            eqnlen = sum(equations{i}.operator.dim(:,1));
            out.n.nr = out.n.nr+eqnlen;
        end
    end
end

% finding max derivative of PDE
N = 0;
for i=1:eqnNum
    statevec = equations{i}.statevec;
    pdeloc = find(strcmp(statevec.state.type,'pde'));
    diff = cell2mat(statevec.diff(pdeloc));
    delta = statevec.delta(pdeloc);
    if ~isempty(diff)
        [maxval,maxdiffloc] = max(diff(:,2));
    else
        maxval = 0;
        maxdiffloc = [];
    end
    delta = delta(maxdiffloc);
    for j=1:length(delta)
        deltavars = delta{j};
        if ~all(deltavars(2).degmat)
            maxval = maxval+1;
        end
    end
    if maxval>N
        N = maxval;
    end
end
out.n.n_pde = zeros(1,N+1);
out.n.n_pde(end) = npde_sum;

% extract ODE params

% extract output params

% extract BC params

% extract PDE params

% extract interconnection signals, v

% extract interconnection signals, r


asdfs=0;
end
function out = identifyEqnType(equation)
statevec = equation.statevec;
classifiedeqns = zeros(length(equation),1);
for i=1:length(statevec)
    if strcmp(statevec(i).type,'ode')
    elseif strcmp(statevec(i).type,'pde')
    elseif strcmp(statevec(i).type,'out')
    end
end

if any(strcmp(statevec.state.type,'out')) %if equation has output
    out = 'out';
elseif any(cellfun(@(x) x(1)~=0, statevec.diff,'un',1))%if term has derivative of time
    if strcmp(statevec.state(find(cellfun(@(x) x(1)~=0, statevec.diff,'un',1))).type,'ode')% ode with derivative of time
        out = 'ode';
    else %pde
        out = 'pde';
    end
else % boundary condition
    out = 'bc';
end
end