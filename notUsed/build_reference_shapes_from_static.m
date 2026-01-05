function Sref = build_reference_shapes_from_static(Marker, segments)
% SREF.(SEG) = 3x4 forme rigide (centrée) depuis le statique
Sref = struct();
for i = 1:numel(segments)
    seg = segments{i};
    P = [ Marker.([seg '_c1']), Marker.([seg '_c2']), ...
          Marker.([seg '_c3']), Marker.([seg '_c4']) ];   % 3x4
    for j=1:4, if all(P(:,j)==0), P(:,j)=NaN; end, end
    if any(isnan(P(:))), error('Forme statique incomplète pour %s.', seg); end
    Sref.(seg) = P - mean(P,2);  % centré: on ne garde que la géométrie
end
end
