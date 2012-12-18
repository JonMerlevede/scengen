function A = reverseA( D )
%DETERMINEA Returns the best estimation of the activation matrix A used for
%           generating D.
%
%   D should be a cell array as retured by readData.
%   If the biggest x- and y-coordinates are not present in the data, the
%   activation matrix will be too small.
    define_Cn
    BD = [D{:,2}];
    BD = BD([cN('pickupX') cN('pickupY') cN('deliveryX') cN('deliveryY')],:);
    BD = floor(BD);
    bX = max(max(BD([1 3],:))); % biggest X coordinate D
    bY = max(max(BD([2 4],:))); % biggest Y coordinate D
    % Preallocate A
    A = zeros(bX - 1, bY - 1);
    % Count the number of pickups and deliveries on each coordinate
    for m=0:4
    for n=0:4
        A(m+1,n+1) = sum(BD(1,:) == n & BD(2,:) == m) ...
            + sum(BD(3,:) == n & BD(4,:) == m); 
    end
    end
    assert(sum(A(:)) == size(BD,2)*2, 'Incorrect package count');
    % Normalise A
    A = A / sum(A(:));
end

