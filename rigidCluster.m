function tX_seg = rigidCluster(X_seg,mode)

tX_seg(:,:,1) = permute(X_seg(:,:,1,:),[4,1,2,3]);
for iframe = 2:size(X_seg,3)
    tX_seg(:,:,iframe) = permute(X_seg(:,:,iframe,:),[4,1,3,2]);
    % Case 1
    [R(:,:,1),d(:,:,1),rms(:,:,1)] = soder(tX_seg([1,2,3],:,iframe-1),tX_seg([1,2,3],:,iframe));
    % Case 2
    [R(:,:,2),d(:,:,2),rms(:,:,2)] = soder(tX_seg([1,2,4],:,iframe-1),tX_seg([1,2,4],:,iframe));
    % Case 3
    [R(:,:,3),d(:,:,3),rms(:,:,3)] = soder(tX_seg([2,3,4],:,iframe-1),tX_seg([2,3,4],:,iframe));
    % Case 4
    [R(:,:,4),d(:,:,4),rms(:,:,4)] = soder(tX_seg([1,3,4],:,iframe-1),tX_seg([1,3,4],:,iframe));
    % Case 5
    [R(:,:,5),d(:,:,5),rms(:,:,5)] = soder(tX_seg([1,2,3,4],:,iframe-1),tX_seg([1,2,3,4],:,iframe));
    if strcmp(mode,'Min')
        % Min deformation choice
        [~,idx] = min(rms);
        tX_seg(:,:,iframe) = (R(:,:,idx)*tX_seg(:,:,iframe-1)'+d(:,:,idx))';
    elseif strcmp(mode,'Max')
        % Max deformation choice
        [~,idx] = max(rms);
        tX_seg(:,:,iframe) = (R(:,:,idx)*tX_seg(:,:,iframe-1)'+d(:,:,idx))';
    elseif strcmp(mode,'Mean')
        % Mean deformation choice
        tX_seg(:,:,iframe) = (R(:,:,5)*tX_seg(:,:,iframe-1)'+d(:,:,5))';
    end
end
tX_seg = permute(tX_seg,[2,4,3,1]);