function plot_frame(T, scale, name, style)
% PLOT_FRAME Trace un repère 3D à partir d'une matrice homogène 4x4
%
% INPUT
%   T     : 4x4 matrice homogène
%   scale : longueur des axes
%   name  : label du repère
%   style : suffixe de style (ex. '-' ou '--')

    if nargin < 2, scale = 20; end
    if nargin < 3, name = ''; end
    if nargin < 4, style = '-'; end

    O = T(1:3,4);        % origine
    X = T(1:3,1)*scale;  % axe X
    Y = T(1:3,2)*scale;  % axe Y
    Z = T(1:3,3)*scale;  % axe Z

    % Tracer les axes
    quiver3(O(1),O(2),O(3),X(1),X(2),X(3),style,'Color','r','LineWidth',2);
    quiver3(O(1),O(2),O(3),Y(1),Y(2),Y(3),style,'Color','g','LineWidth',2);
    quiver3(O(1),O(2),O(3),Z(1),Z(2),Z(3),style,'Color','b','LineWidth',2);

    if ~isempty(name)
        text(O(1),O(2),O(3),[' ' name],'FontSize',10);
    end
end
