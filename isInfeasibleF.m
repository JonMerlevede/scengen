function [ infeasiblePickup, infeasibleDelivery ] = isInfeasibleF( simulationTime, type)
%ISINFEASIBLEF Summary of this function goes here
%   Detailed explanation goes here
if (nargin < 1)
    disp('Not enough input arguments.')
elseif (nargin < 2)
    type = 1;
end

D = readData('existing',strcat(['req*' int2str(simulationTime) '*']));
D = [D{:,2}];
% Gendreau pickup and delivery time is 5 minutes (we could read this from
% the data as well)
pickupDuration = 5*60; % [s]
deliveryDuration = 5*60; % [s]
% Total Gendreau simulation time is simulationTime minutes
simulationTime = simulationTime*60; % [s]
% Speed of Gendreau wagons is 30 km/h
totalSpeed = 30/3600; % [km / s]
define_Cn

tDriveAfterDelivery = sqrt(...
    (D(cN.deliveryX,:) - 2.5).^2 ...
    + (D(cN.deliveryY,:) - 2.5).^2) * (1/totalSpeed);
tDriveAfterPickup = sqrt(...
    (D(cN.pickupX,:) - D(cN.deliveryX,:)).^2 ...
    + (D(cN.pickupY,:) - D(cN.deliveryY,:)).^2) * (1/totalSpeed);
tDriveAfterPickup = tDriveAfterPickup + tDriveAfterDelivery;
% Alternative calculation
% P1 = [D(cN.pickupX,:) ; D(cN.pickupY,:)];
% P2 = [D(cN.deliveryX,:) ; D(cN.deliveryY,:)];
% P3 = repmat(2.5,2,size(D,2));
% tDriveAfterDelivery = sqrt(sum((P2-P3) .* (P2-P3)));
% tDriveAfterPickup = sqrt(sum((P1-P2) .* (P1-P2)));
% tDriveAfterPickup = tDriveAfterPickup + tDriveAfterDelivery;
if (type == 1)
    pT = D(cN.pickupTimeWindowEnd,:) ...
        + pickupDuration ...
        + deliveryDuration ...
        + tDriveAfterPickup;
    dT = D(cN.deliveryTimeWindowEnd,:) ...
        + deliveryDuration ...
        + tDriveAfterDelivery;
elseif (type == 2)
    pT = D(cN.pickupTimeWindowEnd,:) ...
        + tDriveAfterPickup;
    dT = D(cN.deliveryTimeWindowEnd,:) ...
        + tDriveAfterDelivery;
end
infeasiblePickup = any(pT> simulationTime);
infeasibleDelivery = any(dT > simulationTime);
end

