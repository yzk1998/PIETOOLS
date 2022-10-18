function out = getPDEparams(pdeObj)
equations = pdeObj.equation;
statelist = pdeObj.states;
eqnNum = length(equations);

% temporary pvars
pvar t;

% build a dictionary of state names for future reference
odeNames = statelist(find(strcmp(statelist.type,'ode'))).statename;
pdeNames = statelist(find(strcmp(statelist.type,'pde'))).statename;
xNames = [odeNames; pdeNames];
zNames = statelist(find((~pdeObj.ObservedOutputs).*strcmp(statelist.type,'out'))).statename;
yNames = statelist(find(pdeObj.ObservedOutputs.*strcmp(statelist.type,'out'))).statename;  
uNames = statelist(find(pdeObj.ControlledInputs.*strcmp(statelist.type,'in'))).statename;
wNames = statelist(find(~(pdeObj.ControlledInputs).*strcmp(statelist.type,'in'))).statename;

% find the term location of states in the equation
veclen_sum = [0;cumsum(equations.statevec.veclength)]+1;
odeidx = find(strcmp(equations.statevec.type,'ode')); % find all terms with ode states
pdeidx = find(strcmp(equations.statevec.type,'pde')); % find all terms with pde states
outidx = find(strcmp(equations.statevec.type,'out')); % find all terms with output 
inidx = find(strcmp(equations.statevec.type,'in')); % find all terms with input



% start parsing the system equations
out = pde_struct();

% set known global properties 
out.dim = 1;
out.dom = [0,1];
out.vars = [pvar('s'),pvar('theta')];

% set state properties
out.x = cell(length(xNames),1);
out.w = cell(length(wNames),1);
out.u = cell(length(uNames),1);
out.z = cell(length(zNames),1);
out.y = cell(length(yNames),1);
out.BC = cell(0,1);


% specify ode locations in out.x
[~,tmpidx] = ismember(odeNames,xNames);
if ~isempty(tmpidx)
out.x{tmpidx}.vars = [];
end



isdot_A = isdot(equations.statevec); isout_A=isout(equations.statevec); 
for i=1:eqnNum
    row = equations(i);
    if any(isout_A'&~isequal(polynomial(row.operator.R.R0),zeros(1,sum(equations.statevec.veclength)))) % equation has outputs
        % find which output 
        outLoc = find(isout_A'&~isequal(polynomial(row.operator.R.R0),zeros(1,sum(equations.statevec.veclength))));
        outLoc = find(outLoc<veclen_sum,1)-1;
        outNametemp = equations.statevec(outLoc).statename;
        if ismember(outNametemp, zNames)% regulated output
            tmp = out.z;
            Loc = find(outNametemp == zNames); 
        else % observed output
            tmp = out.y;
            Loc = find(outNametemp == yNames); 
        end
        % now separate the terms
        for j=1:length(equations.statevec)
            if ~isfield(tmp{Loc},'term')||(length(tmp{Loc}.term)<j) % term is not initialized 
                tmp{Loc}.term{j}.C = [];
            end
            if strcmp(equations.statevec(j).type,'ode')% ode state term
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{Loc}.term{j}.x = find(equations.statevec(j).statename==xNames);
            elseif strcmp(equations.statevec(j).type,'pde')% pde state term
                tmp{Loc}.term{j}.x = find(equations.statevec(j).statename==xNames);
                if any(~isequal(polynomial(row.operator.R.R1(:,veclen_sum(j):veclen_sum(j+1)-1)),zeros(1,equations.statevec(j).veclength)))% integral term
                    tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R1(:,veclen_sum(j):veclen_sum(j+1)-1)];
                    tmp{Loc}.term{j}.D = equations.statevec(j).diff_order(2);
                    tmp{Loc}.term{j}.I{1} = [0,1];
                else % boundary term
                    tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                    tmp{Loc}.term{j}.loc = equations.statevec(j).var(2);
                    tmp{Loc}.term{j}.D = equations.statevec(j).diff_order(2);
                end
            elseif ismember(equations.statevec(j).statename,wNames) % disturbance term
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{Loc}.term{j}.w = find(equations.statevec(j).statename==wNames);
            elseif ismember(equations.statevec(j).statename,uNames)% control input term
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{Loc}.term{j}.u = find(equations.statevec(j).statename==uNames);
            end
            % extract delay term, if it exists
            if double(equations.statevec(j).var(1)-t) % non-zero delay term
                tmp{Loc}.term{j}.delay = double(equations.statevec(j).var(1)-t);
            end
        end
        if ismember(outNametemp, zNames)% regulated output
            out.z = tmp;
        else % observed output
            out.y = tmp;
        end
    elseif any(isdot_A'&~isequal(polynomial(row.operator.R.R0),zeros(1,sum(equations.statevec.veclength))))% equation has dynamics
        % find which x
        outLoc = find(isdot_A'.*any(strcmp(equations.statevec.type,{'ode'})|strcmp(equations.statevec.type,{'pde'}))'&~isequal(polynomial(row.operator.R.R0),zeros(1,sum(equations.statevec.veclength))));
        outLoc = find(outLoc<veclen_sum,1)-1;
        outNametemp = equations.statevec(outLoc).statename;
        tmp = out.x;
        Loc = find(outNametemp == xNames); 
        % now separate the terms
        for j=1:length(equations.statevec) % first extract all the R0 terms
            if ~isfield(tmp{Loc},'term')||(length(tmp{Loc}.term)<j) % term is not initialized 
                tmp{Loc}.term{j}.C = [];
            end
            if (j==outLoc) % derivative term, ignore
                continue;
            end
            if strcmp(equations.statevec(j).type,'ode')% ode state term
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{Loc}.term{j}.x = find(equations.statevec(j).statename==xNames);
            elseif strcmp(equations.statevec(j).type,'pde')% pde state term
                tmp{Loc}.term{j}.x = find(equations.statevec(j).statename==xNames);
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                if poly2double(equations.statevec(j).var(2)) % boundary term
                    tmp{Loc}.term{j}.loc = equations.statevec(j).var(2);
                end
                tmp{Loc}.term{j}.D = equations.statevec(j).diff_order(2);
            elseif ismember(equations.statevec(j).statename,wNames) % disturbance term
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{Loc}.term{j}.w = find(equations.statevec(j).statename==wNames);
            elseif ismember(equations.statevec(j).statename,uNames)% control input term
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{Loc}.term{j}.u = find(equations.statevec(j).statename==uNames);
            end
            % extract delay term, if it exists
            if double(equations.statevec(j).var(1)-t) % non-zero delay term
                tmp{Loc}.term{j}.delay = double(equations.statevec(j).var(1)-t);
            end
        end
        for j = length(equations.statevec)+1:2*length(equations.statevec) % extract all the R1 terms
            jtmp = j- length(equations.statevec);
            if ~isfield(tmp{Loc},'term')||(length(tmp{Loc}.term)<j) % term is not initialized 
                tmp{Loc}.term{j}.C = [];
            end
            if any(~isequal(polynomial(row.operator.R.R1(:,veclen_sum(jtmp):veclen_sum(jtmp+1)-1)),zeros(1,equations.statevec(jtmp).veclength)))% integral term
                tmp{Loc}.term{j}.I{1} = [0,pvar('s')];
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R1(:,veclen_sum(jtmp):veclen_sum(jtmp+1)-1)];
                tmp{Loc}.term{j}.D = equations.statevec(jtmp).diff_order(2);
                tmp{Loc}.term{j}.x = find(equations.statevec(jtmp).statename==xNames);
            end
            % extract delay term, if it exists
            if double(equations.statevec(jtmp).var(1)-t) % non-zero delay term
                tmp{Loc}.term{j}.delay = double(equations.statevec(jtmp).var(1)-t);
            end
        end
        for j = 2*length(equations.statevec)+1:3*length(equations.statevec) % extract all the R2 terms
            jtmp = j- 2*length(equations.statevec);
            if ~isfield(tmp{Loc},'term')||(length(tmp{Loc}.term)<j) % term is not initialized 
                tmp{Loc}.term{j}.C = [];
            end
            if any(~isequal(polynomial(row.operator.R.R2(:,veclen_sum(jtmp):veclen_sum(jtmp+1)-1)),zeros(1,equations.statevec(jtmp).veclength)))% integral term
                tmp{Loc}.term{j}.I{1} = [pvar('s'),1]; 
                tmp{Loc}.term{j}.C = [tmp{Loc}.term{j}.C; -row.operator.R.R2(:,veclen_sum(jtmp):veclen_sum(jtmp+1)-1)];
                tmp{Loc}.term{j}.D = equations.statevec(jtmp).diff_order(2);
                tmp{Loc}.term{j}.x = find(equations.statevec(jtmp).statename==xNames);
            end
            % extract delay term, if it exists
            if double(equations.statevec(jtmp).var(1)-t) % non-zero delay term
                tmp{Loc}.term{j}.delay = double(equations.statevec(jtmp).var(1)-t);
            end
        end
        out.x = tmp;
    else % boundary conditions
        tmp = out.BC;
        k = length(tmp);
        tmp{k+1} = [];
        for j=1:length(equations.statevec)
            if ~isfield(tmp{k+1},'term')||(length(tmp{k+1}.term)<j) % term is not initialized 
                tmp{k+1}.term{j}.C = [];
            end
            if strcmp(equations.statevec(j).type,'ode')% ode state term
                tmp{k+1}.term{j}.C = [tmp{k+1}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{k+1}.term{j}.x = find(equations.statevec(j).statename==xNames);
            elseif strcmp(equations.statevec(j).type,'pde')% pde state term
                tmp{k+1}.term{j}.x = find(equations.statevec(j).statename==xNames);
                if ~isequal(polynomial(row.operator.R.R1(:,veclen_sum(j):veclen_sum(j+1)-1)),zeros(1,equations.statevec(j).veclength))% integral term
                    tmp{k+1}.term{j}.C = [tmp{k+1}.term{j}.C; -row.operator.R.R1(:,veclen_sum(j):veclen_sum(j+1)-1)];
                    tmp{k+1}.term{j}.D = equations.statevec(j).diff_order(2);
                    tmp{k+1}.term{j}.I{1} = [0,1];
                else % boundary term
                    tmp{k+1}.term{j}.C = [tmp{k+1}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                    tmp{k+1}.term{j}.loc = equations.statevec(j).var(2);
                    tmp{k+1}.term{j}.D = equations.statevec(j).diff_order(2);
                end
            elseif ismember(equations.statevec(j).statename,wNames) % disturbance term
                tmp{k+1}.term{j}.C = [tmp{k+1}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{k+1}.term{j}.w = find(equations.statevec(j).statename==wNames);
            elseif ismember(equations.statevec(j).statename,uNames)% control input term
                tmp{k+1}.term{j}.C = [tmp{k+1}.term{j}.C; -row.operator.R.R0(:,veclen_sum(j):veclen_sum(j+1)-1)];
                tmp{k+1}.term{j}.u = find(equations.statevec(j).statename==uNames);
            end
            % extract delay term, if it exists
            if double(equations.statevec(j).var(1)-t) % non-zero delay term
                tmp{k+1}.term{j}.delay = double(equations.statevec(j).var(1)-t);
            end
        end
        out.BC = tmp;
    end
end

% finally remove empty/zero terms
% dotidx = find(isdot_A); outidx = find(isout_A); rmidx = [dotidx;outidx];
for i=1:length(xNames)
    for j=length(out.x{i}.term):-1:1
        coeffvec = out.x{i}.term{j}.C(:);
        if isempty(coeffvec)
            out.x{i}.term(j) = [];
        elseif all(isequal(polynomial(coeffvec),zeros(length(coeffvec),1)))
            out.x{i}.term(j) = [];
        end
    end
%     rmidx2 = [rmidx; (rmidx+length(out.x{i}.term)/3); (rmidx+2*length(out.x{i}.term)/3)];
%     out.x{i}.term(rmidx2) = [];
end
for i=1:length(zNames)
    for j=length(out.z{i}.term):-1:1
        coeffvec = out.z{i}.term{j}.C(:);
        if isempty(coeffvec)
            out.z{i}.term(j) = [];
        elseif all(isequal(polynomial(coeffvec),zeros(length(coeffvec),1)))
            out.z{i}.term(j) = [];
        end
    end
% out.z{i}.term(rmidx) = [];
end
for i=1:length(yNames)
    for j=length(out.y{i}.term):-1:1
        coeffvec = out.y{i}.term{j}.C(:);
        if isempty(coeffvec)
            out.y{i}.term(j) = [];
        elseif all(isequal(polynomial(coeffvec),zeros(length(coeffvec),1)))
            out.y{i}.term(j) = [];
        end
    end
% out.y{i}.term(rmidx) = [];
end
for i=1:length(out.BC)
    for j=length(out.BC{i}.term):-1:1
        coeffvec = out.BC{i}.term{j}.C(:);
        if isempty(coeffvec)
            out.BC{i}.term(j) = [];
        elseif all(isequal(polynomial(coeffvec),zeros(length(coeffvec),1)))
            out.BC{i}.term(j) = [];
        end
    end
% out.BC{i}.term(rmidx) = [];
end
end
