function data = zerosToNaN_array3(data)
% Remplace les triplets (0,0,0) par (NaN,NaN,NaN)
% Compatible avec format 3x1xT

if ndims(data) == 3 && size(data,1) == 3 && size(data,2) == 1
    T = size(data,3);
    for t = 1:T
        if all(data(:,1,t) == 0)
            data(:,1,t) = NaN;
        end
    end
elseif ismatrix(data) && size(data,2) == 3
    % cas ancien format Tx3
    mask = all(data == 0, 2);
    data(mask,:) = NaN;
else
    warning('Format inattendu : attendu 3x1xT ou Tx3');
end
end
