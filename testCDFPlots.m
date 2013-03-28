function testCDFPlots

figure(1); clf;
[mD,eD] = localReadData('*240_24');
makePlots(mD,eD);
mtit('Short scenarios, 24 requests / hour');
figure(2); clf;
[mD,eD] = localReadData('*240_33');
makePlots(mD,eD);
mtit('Short scenarios, 33 requests / hour');
figure(3); clf;
[mD,eD] = localReadData('*450_24');
makePlots(mD,eD);
mtit('Long scenarios, 24 requests / hour');
end

function [myData, existingData] = localReadData(regexp)
myCell = readData('output',regexp);
myData = [myCell{:,2}];
existingCell = readData('existing',regexp);
existingData = [existingCell{:,2}];
end

function makePlots(myData,existingData)
define_Cn
nV = 5;
nH = 2;

subplot(nV,nH,1);hold on;
    title('Delivery - X coordinate')
    [f1,x1] = ecdf(myData(cN.deliveryX,:));
    [f2,x2] = ecdf(existingData(cN.deliveryX,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,2);hold on;
    title('Delivery - Y coordinate')
    [f1,x1] = ecdf(myData(cN.deliveryY,:));
    [f2,x2] = ecdf(existingData(cN.deliveryY,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,3);hold on;
    title('Pickup - X coordinate')
    [f1,x1] = ecdf(myData(cN.pickupX,:));
    [f2,x2] = ecdf(existingData(cN.pickupX,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,4);hold on;
    title('Pickup - Y coordinate')
    [f1,x1] = ecdf(myData(cN.pickupY,:));
    [f2,x2] = ecdf(existingData(cN.pickupY,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,5);hold on;
    title('Delivery - begin of time window')
    [f1,x1] = ecdf(myData(cN.deliveryTimeWindowBegin,:));
    [f2,x2] = ecdf(existingData(cN.deliveryTimeWindowBegin,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,6);hold on;
    title('Delivery - end of time window')
    [f1,x1] = ecdf(myData(cN.deliveryTimeWindowEnd,:));
    [f2,x2] = ecdf(existingData(cN.deliveryTimeWindowEnd,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,7);hold on;
    title('Pickup - begin of time window')
    [f1,x1] = ecdf(myData(cN.pickupTimeWindowBegin,:));
    [f2,x2] = ecdf(existingData(cN.pickupTimeWindowBegin,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,8);hold on;
    title('Pickup - end of time window')
    [f1,x1] = ecdf(myData(cN.pickupTimeWindowEnd,:));
    [f2,x2] = ecdf(existingData(cN.pickupTimeWindowEnd,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
subplot(nV,nH,[9 10]);hold on;
    title('Request arrival times')
    [f1,x1] = ecdf(myData(cN.requestArrivalTime,:));
    [f2,x2] = ecdf(existingData(cN.requestArrivalTime,:));
    plot(x1,f1,'r');
    plot(x2,f2,'g');
end