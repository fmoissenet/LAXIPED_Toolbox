function out = readLaxipedFile(filepath)
% READMEASUREMENTFILE (v2) : gère les lignes intermédiaires (ex. "Heel initial force")
% Sortie :
%   out.metadata : struct
%   out.data     : table (Cycle, F1_N, D1_mm, F2_N, D2_mm, D_diff_mm, F_tot_N, time_s, F_heel_mV)

txt   = fileread(filepath);
lines = regexp(txt, '\r?\n', 'split');

% --- Métadonnées
md = struct();
for i = 1:numel(lines)
    L = strtrim(lines{i});

    tok = regexp(L,'^Selected mode is\s+(.+?)\s+with both motors selected','tokens','once','ignorecase');
    if ~isempty(tok), md.selected_mode = tok{1}; continue; end

    tok = regexp(L,'^Selected pads are\s+(.+)$','tokens','once','ignorecase');
    if ~isempty(tok), md.selected_pads = tok{1}; continue; end

    tok = regexp(L,'^This is the measurement n\.\s*(\d+)','tokens','once','ignorecase');
    if ~isempty(tok), md.measurement_number = str2double(tok{1}); continue; end

    tok = regexp(L,'^Procedure mode:\s*(.+)$','tokens','once','ignorecase');
    if ~isempty(tok), md.procedure_mode = tok{1}; continue; end

    tok = regexp(L,'^ToF distance from right sensor:\s*([\d\.]+)\s*mm','tokens','once','ignorecase');
    if ~isempty(tok), md.tof_right_sensor_mm = str2double(tok{1}); continue; end

    if ~isfield(md,'raw_header') && startsWith(L,'F1','IgnoreCase',true)
        md.raw_header = L;
    end
end

% --- Parse des cycles + données
cycles = [];
rows   = [];

i = 1;
while i <= numel(lines)
    L = strtrim(lines{i});
    cyc = regexp(L,'^measurement cycle:\s*(\d+)\s*$','tokens','once','ignorecase');
    if isempty(cyc)
        i = i + 1;
        continue;
    end

    cycNum = str2double(cyc{1});

    % Cherche la première ligne avec >= 8 nombres (ignore tout le reste)
    j = i + 1;
    found = false;
    while j <= numel(lines)
        cand = strtrim(lines{j});
        % Remplacer les virgules comme séparateurs éventuels
        cand = regexprep(cand, ',', ' ');
        % Extraire les nombres (supporte 1.23, -4, 5e-3)
        nums = regexp(cand, '[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?', 'match');
        if numel(nums) >= 8
            vals = str2double(nums(1:8));
            cycles(end+1,1)   = cycNum;        %#ok<AGROW>
            rows(end+1,1:8)   = vals(:).';     %#ok<AGROW>
            found = true;
            j = j + 1;
            break;
        else
            j = j + 1; % saute lignes telles que "Heel initial force: 0.000"
        end
    end
    i = j;
    if ~found
        % Aucun paquet numérique trouvé pour ce cycle : on passe au suivant
        i = i + 1;
    end
end

% --- Table résultat
varNames = {'F1_N','D1_mm','F2_N','D2_mm','D_diff_mm','F_tot_N','time_s','F_heel_mV'};
if isempty(rows)
    T = cell2table(cell(0, numel(varNames)), 'VariableNames', varNames);
    T.Cycle = zeros(0,1);
else
    T = array2table(rows, 'VariableNames', varNames);
    T.Cycle = cycles;
end
T = movevars(T,'Cycle','Before',1);

out = struct('metadata', md, 'data', T);
end
