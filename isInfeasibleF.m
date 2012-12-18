function [ infeasiblePickup, infeasibleDelivery ] = isInfeasibleF( folder, simulationTime, type)
%ISINFEASIBLEF Checks if one of the pickups or deliveries in the simulation
% files in folder with times simulationTime are infeasible.
%
%   - If type == 1, pickups or dropoffs are considered infeasible if it is not
%       possible to pick them up and drop them off or drop them off and get back
%       to the depot before the simulation is over, i.e. they are
%       considered infeasible if it is impossible for the simulation to end
%       within the simulation time.
%   - If type == 2, pickups or dropoffs are considered infeasible if
%       the beginning of the pickup or dropoff window plus the time that has to
%       be spent driving before the truck is back at the depot is greater
%       than the simultion time. This includes driving from pickup location to
%       dropoff location in the case of the pickup window.
%       This definition of 'feasibility' does not take into account pickup- and
%       dropoff times. For feasible scenarios it might still be impossible to
%       end within the simulation time.
%       This is the definition of feasiblity used by Gendreau.
%    - simulationTime is specified in minutes (Gendreau uses values of 240 and
%       450).
%
%   The default value of type is 1.
%
%   Simulations considered infeasible for type = 2 are always considered
%   infeasible for type = 1, but the reverse is not true.

%% Input verification
if (nargin < 2)
    disp('Not enough input arguments.')
elseif (nargin < 3)
    type = 1;
end

%% Read data and set known variables
D = readData(folder,strcat(['*req*' int2str(simulationTime) '*']));
D = [D{:,2}];
% Gendreau pickup and delivery time is 5 minutes (we could read this from
% the data as well). We really do not need these variables if type == 2.
pickupDuration = 5*60; % [s]
deliveryDuration = 5*60; % [s]
% Total Gendreau simulation time is simulationTime minutes
simulationTime = simulationTime*60; % [s]
% Speed of Gendreau wagons is 30 km/h
totalSpeed = 30/3600; % [km / s]
define_Cn

%% Determine driving times
% Distance from delivery to depot location / speed
tDriveAfterDelivery = sqrt( ...
      (D(cN.deliveryX,:) - 2.5).^2 ...
    + (D(cN.deliveryY,:) - 2.5).^2) * (1/totalSpeed);
% Distance from pickup to delivery location / speed
tDriveAfterPickup = sqrt( ...
      (D(cN.pickupX,:) - D(cN.deliveryX,:)).^2 ...
    + (D(cN.pickupY,:) - D(cN.deliveryY,:)).^2) * (1/totalSpeed);
% Distance from pickup to delivery to depot location / speed
tDriveAfterPickup = tDriveAfterPickup + tDriveAfterDelivery;
% Alternative (identical) calculation
% P1 = [D(cN.pickupX,:) ; D(cN.pickupY,:)];
% P2 = [D(cN.deliveryX,:) ; D(cN.deliveryY,:)];
% P3 = repmat(2.5,2,size(D,2));
% tDriveAfterDelivery = sqrt(sum((P2-P3) .* (P2-P3))) * (1/totalSpeed);
% tDriveAfterPickup = sqrt(sum((P1-P2) .* (P1-P2))) * (1/totalSpeed);
% tDriveAfterPickup = tDriveAfterPickup + tDriveAfterDelivery;

%% Determine feasibility
if type == 1
    pT = D(cN.pickupTimeWindowBegin,:) ...
        + pickupDuration ...
        + deliveryDuration ...
        + tDriveAfterPickup;
    dT = D(cN.deliveryTimeWindowBegin,:) ...
        + deliveryDuration ...
        + tDriveAfterDelivery;
elseif type == 2
    pT = D(cN.pickupTimeWindowBegin,:) ...
        + tDriveAfterPickup;
    dT = D(cN.deliveryTimeWindowBegin,:) ...
        + tDriveAfterDelivery;
end
infeasiblePickup = any(pT> simulationTime);
infeasibleDelivery = any(dT > simulationTime);
end

