% Give convenient names for the columns we'll read in
keySet = {'requestArrivalTime'
    'pickupServiceTime'
    'pickupX';'pickupY'
    'pickupTimeWindowBegin';'pickupTimeWindowEnd'
    'deliveryServiceTime'
    'deliveryX';'deliveryY'
    'deliveryTimeWindowBegin';'deliveryTimeWindowEnd'};
valueSet = 1:11;
cN = containers.Map(keySet, valueSet);