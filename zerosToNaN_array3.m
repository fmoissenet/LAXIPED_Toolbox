% Author     :   F. Moissenet
%                Biomechanics Laboratory (B-LAB)
%                University of Geneva
% License    :   Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code:   To be defined
% Reference  :   To be defined
% Date       :   October 2025
% -------------------------------------------------------------------------
% Description:   Part of the LAXIPED project
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function data = zerosToNaN_array3(data)

for t = 1:size(data,3)
    if all(data(:,1,t) == 0)
        data(:,1,t) = NaN;
    end
end
