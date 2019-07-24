function F = F1(clustersA,clustersB)
%F1 Summary of this function goes here
%   Detailed explanation goes here
clustersA = clustersA(:)';
clustersB = clustersB(:)';
N = length(clustersA); %should be the same for clustersB
A_labels = unique(clustersA);
PA = zeros(size(A_labels));
for a=1:length(A_labels)
    PA(a) = sum(clustersA==A_labels(a))/N;
end
B_labels = unique(clustersB);
PB = zeros(size(B_labels));
for b=1:length(B_labels)
    PB(b) = sum(clustersB==B_labels(b))/N;
end
PAIB = zeros(length(A_labels), length(B_labels));
PBIA = zeros(length(B_labels), length(A_labels));
for a=1:length(A_labels)
    A = A_labels(a);
    for b=1:length(B_labels)
        B = B_labels(b);
        PAandB = sum(clustersA == A & clustersB == B)/N;
        PAIB(a,b) = PAandB/PB(b);
        PBIA(b,a) = PAandB/PA(a);
    end
end
[~, fa] = max(PBIA);
[~, gb] = max(PAIB);

R = sum(PA.*PBIA(sub2ind(size(PBIA),fa,1:length(PA))));
P = sum(PB.*PAIB(sub2ind(size(PAIB),gb,1:length(PB))));

F = 2*P*R/(P+R);