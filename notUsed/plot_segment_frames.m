function plot_segment_frames(T_a, T_t, T_ta, segName, scale)
% PLOT_SEGMENT_FRAMES Trace les repères d'un segment :
% - repère anatomique (plein)
% - repère technique (plein)
% - repère technique transformé en anatomique (pointillé)

if nargin < 5, scale = 30; end

% Anatomique
plot_frame(T_a, scale, [segName ' Anat'], '-');

% % Technique
% plot_frame(T_t, scale, [segName ' Tech'], '-');
% 
% % Technique exprimé dans l'anatomique
% T_t_in_a = Mprod_array3(T_t, T_ta); % équivalent T_a
% plot_frame(T_t_in_a, scale, [segName ' Tech→Anat'], '--');
end
