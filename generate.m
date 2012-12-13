%% In  Java we interpret the output file like this
%
% * |requestArrivalTime = (long) (Double.parseDouble(parts[0]) * 1000.0)|
% * |pickupServiceTime = Long.parseLong(parts[1]) * 1000|
% * |pickupX = Double.parseDouble(parts[2])|
% * |pickupY = Double.parseDouble(parts[3])|
% * |pickupTimeWindowBegin = (long) (Double.parseDouble(parts[4]) * 1000.0)|
% * |pickupTimeWindowEnd = (long) (Double.parseDouble(parts[5]) * 1000.0)|
% * |deliveryServiceTime = Long.parseLong(parts[6]) * 1000|
% * |deliveryX = Double.parseDouble(parts[7])|
% * |deliveryY = Double.parseDouble(parts[8])|
% * |deliveryTimeWindowBegin = (long) (Double.parseDouble(parts[9]) * 1000.0)|
% * |deliveryTimeWindowEnd = (long) (Double.parseDouble(parts[10]) * 1000.0)|

%%Fixed parameters
% These parameters are currently set as described in section 6.1 of
% Gendreau's article.
%
% For the poisson intensity parameters we have
%
% # Set that corresponds to an average of 33 requests / hour
% # Set that corresponds to an average of 24 requests / hour
%
% Remarks:
%
% # In the description of 5.1 it seems as if $$A$ should really be
% dependent of time and therefore be denoted $$A^l$. A zone $$p$
% corresponds to a position, which is a tuple $$(i,j)$. In the simulation
% we assume that $$A$ is not dependent of time (see section 6.1 in the
% paper).
% Speed in km/s
input.speed = 30;     
aw = 5;% Width of the area in km
ah = 5;% Height of the area in km
input.pickupDuration = 5*60;% Pickup service time in seconds
input.deliveryDuration = 5*60;% Delivery service time in seconds
totalSimulationTime = 4*60*60;% Total simulation length in seconds
input.minimumSeparation = 30*60;% Minimum time between announce and latest pickup in seconds
% A = ones(aw,ah); % uniform activity matrix.
 A = [1 1 2 3  2
      1 6 6 6  6
      2 6 9 9  9
      3 6 9 13 9
      2 6 9 9  9]; % matrix like described
% A = [0 0 0 0 0
%      0 0 0 0 0
%      0 1 0 0 0
%      0 0 0 0 0
%      0 0 0 0 1]; % matrix to test
% Normalize matrix
input.A = A * (1/sum(A(:)));
% Period lengths in minutes.
periodLength = [1 1 .5 1 1 ].';
input.periodLength = periodLength/sum(periodLength)*(totalSimulationTime/60);
% Poisson intensity parameters specified in requests / minute.
% input.poissonPeriodIntensities = [0.75 1.10 0.25 0.40 0.10].'; % 33 / minute
input.poissonPeriodIntensities = [0.55 0.70 0.10 0.40 0.10].'; % 24 / minute
% Delta values
input.pickupDeltas = [0.1 ; 0.8];
input.deliveryDeltas = [0.3 ; 1.0];

%%
tic
for k=1:1
    output = createSimulation(input);
    %fprintf('Generated %d packets.\n',length(output))
    dlmwrite(sprintf('req_rapide_%d_240_24',k),output.',' ')
end
toc
disp('Created 10 solutions.')