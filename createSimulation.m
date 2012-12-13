function [ output ] = createSimulation( I )
%CREATESIMULATION Creates simulation matrix using given input structure.
%   input is a structure that has the fields
%   - A: activity matrix [-]
%   - speed: speed of vehicles [km/h]
%   - periodLength: poisson period intensities [minutes]
%   - poissonPeriodIntensities: poisson period intensities [requests / minute]
%   - pickupDuration: pickup duration [seconds]
%   - deliveryDuration: delivery duration [seconds]
%   
%   Optional fields:
%   - minimumSeparation: minimum time between packet announce time and the
%     end of the pickup time window [seconds]
%   - verbose: if present, script is more verbose
    
    %% Validate input
    validateInput(I);

    %% Process input
    % Verbosity
    verbose = isfield(I,'verbose');
    % Number of (discrete) time periods
    nPeriods = length(I.periodLength);
    % Total simulation time [seconds]
    totalSimulationTime = sum(I.periodLength)*60;
    % Period start times [seconds]
    periodStartTimes = cumsum(I.periodLength)-I.periodLength;
    % Speed of the vehicles [km/s]
    speed = I.speed/60/60;
    % Minimum time between packet announce time and the end of the pickup
    % time window [seconds]
    if isfield(I, 'minimumSeparation'), minimumSeparation = I.minimumSeparation;
    else minimumSeparation = 0; end
    % Width and height of the area [km]
    [ah aw] = size(I.A);
    

    %% Process the activity matrix
    P = I.A(:)*I.A(:).';
    P = reshape(P,ah,aw,ah,aw);
    PP = cumsum(P(:));
    assert(numel(P) == ah*aw*ah*aw);
    assert(P(3,2,1,1) == I.A(3,2) * I.A(1,1));
    
    
    %% Determine number of (possible) packets
    % Preallocate for speed (three times average length required)
    requestPeriods = zeros(round(sum(I.poissonPeriodIntensities .* I.periodLength)) * 3,1);
    nRequests = 0;
    for l = 1:nPeriods
        nRequestsThisPeriod = poissrnd(I.poissonPeriodIntensities(l)*I.periodLength(l));
        newNRequests = nRequests + nRequestsThisPeriod;
        requestPeriods(nRequests + 1:newNRequests) = repmat(l,nRequestsThisPeriod,1);
        nRequests = newNRequests;
    end
    requestPeriods = requestPeriods(1:nRequests);
    nValidRequests = 0;
    output = zeros(11,nRequests);
    
    %% Looping
    for k = 1:nRequests
        period = requestPeriods(k);
        % Determine packet announce time
        % THIS MIGHT VERY WELL BE INCORRECT
        % Page 166 tells us that 'a poisson law of intensity lambda^l is
        % applied to determine the time of occurence of the next request', but
        % lambda is expressed in requests / minute and we already use lambda to
        % determine the number of packages we generate. Also, a Poisson
        % distribution only produces integer values that are (at least for the
        % given lambdas) fairly close to zero.
        requestArrivalTime = periodStartTimes(period) + rand*I.periodLength(period);
        requestArrivalTime = requestArrivalTime*60;
        
        %% Determine packet position
        % Determine position square index
        iPos = min([find(PP > rand,1) length(PP)]);
        [ppY ppX dpY dpX] = ind2sub([ah aw ah aw],iPos); % square position
        pos = [ppX;ppY;dpX;dpY] - ones(4,1) + rand(4,1); % uniform random position within square
        pP = pos(1:2); % pickup point
        dP = pos(3:4); % delivery point
        
        
        %% Determine windows
        % I DO KNOW WHAT THE CURRENT TIME IS. I THINK THIS IS THE REQUEST
        % ARRIVAL TIME.
        cT = requestArrivalTime; % current time
        % Minimum travel time after delivery in seconds
        mttDelivery = norm(dP)/speed;
        % Minimum travel time between pickup and delivery in seconds
        mttBetween = norm(dP-pP)/speed;
        % Latest feasible time to start a delivery
        lftDelivery = totalSimulationTime - mttDelivery - I.deliveryDuration;
        % Latest feasible time to start a pickup
        lftPickup = lftDelivery - mttBetween - I.pickupDuration;
        if lftPickup <= cT
            cdisp('Dismissing package: infeasible packet')
            continue; % call is not accepted
        end

        %% Deterimine pickup time window

        % Determine halftime for pickup
        ht = (cT + lftPickup)/2;
        % Determine random pickup beta value
        beta = 0.6 + 0.4*rand;
        if rand < beta
            ptwBegin = cT + (ht - cT)*rand;
        else
            ptwBegin = ht + (lftPickup - ht)*rand;
        end
        remainingTime = lftPickup - (ptwBegin + I.pickupDuration);
        remainingTimeFraction = I.pickupDeltas(1) + diff(I.pickupDeltas)*rand;
        ptwEnd = ptwBegin + I.pickupDuration + remainingTime*remainingTimeFraction;

        %% Determine dropoff time window

        % Earliest time we can start pickup
        earliestPossible = ptwBegin + I.pickupDuration + mttBetween;
        % Determine halftime for delivery
        ht = (earliestPossible + lftDelivery) / 2;
        % Determine random delivery beta value
        beta = 0.6 + 0.4*rand;
        if rand < beta
            dtwBegin = earliestPossible + (ht - earliestPossible)*rand;
        else
            dtwBegin = ht + (lftDelivery - ht)*rand;
        end
        remainingTime = lftDelivery - (dtwBegin + I.deliveryDuration);
        remainingTimeFraction = I.deliveryDeltas(1) + diff(I.deliveryDeltas)*rand;
        dtwEnd = dtwBegin + I.deliveryDuration + remainingTime*remainingTimeFraction;

        %% Discard calls
        if (ptwEnd < requestArrivalTime + minimumSeparation)
            cdisp('Dismissing package: minimum separation not met\n');
            continue;
        end

        %% Write delivery information to output matrix
        nValidRequests = nValidRequests + 1;
        output(:,nValidRequests) = [requestArrivalTime
            I.pickupDuration
            pP(1) ; pP(2)
            ptwBegin ; ptwEnd
            I.deliveryDuration
            dP(1) ; dP(2)
            dtwBegin ; dtwEnd];
    end
    % Reduce size of output matrix
    output = output(:,1:nValidRequests);
    
    function cdisp (string)
        if verbose
            show(string);
        end
    end
end

function validateInput(I)
    requiredFields = {...
        'A'
        'speed'
        'pickupDuration'
        'deliveryDuration'
        'periodLength'
        'poissonPeriodIntensities'
        'pickupDeltas'
        'deliveryDeltas'};
    for k=1:length(requiredFields)
        assert(...
            isfield(I,requiredFields{k}), ...
            sprintf('Missing required input: %s',requiredFields{k}))
    end
    assert(length(I.periodLength) == length(I.poissonPeriodIntensities), ...
        'periodLength and poissonPeriodIntensities have to have the same length')
    assert(length(I.pickupDeltas) == 2, ...
        'pickupDeltas has to have length 2')
    assert(length(I.deliveryDeltas) == 2, ...
        'deliveryDeltas has to have length 2')
    assert(I.speed > 0,...
        'speed needs to be strictly positive')
    assert(all(I.poissonPeriodIntensities >= 0), ...
        'Poisson intensities need to be positive');
    assert(I.pickupDuration >= 0, 'Pickup duration needs to be positive.');
    assert(I.deliveryDuration >= 0, 'Delivery duration needs to be positive.');
    e = 10^-5; s = sum(I.A(:));
    assert(s < 1 + e && s > 1 - e, 'A is not a valid activity matrix.');
end