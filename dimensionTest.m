xStretch = 4/5;
yStretch = 1;
Ax = reverseA(readData('existing','req*'),xStretch,yStretch);
xStretch = 1;
yStretch = 4/5;
Ay = reverseA(readData('existing','req*'),xStretch,yStretch);

subplot(1,2,1)
    surf(Ax)
    title('Activation matrix using 4 horizontal and 5 vertical zones');
    xlabel('y-coordinate'), ylabel('x-coordinate'), zlabel('frequency')
subplot(1,2,2)
    surf(Ay)
    title('Activation matrix using 5 vertical and 4 horizontal zones');
    xlabel('y-coordinate'), ylabel('x-coordinate'), zlabel('frequency')

