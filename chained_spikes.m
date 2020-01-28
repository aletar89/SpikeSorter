function [chained] = chained_spikes(data,detections)

N_of_spikes = length(detections);
chained = zeros(N_of_spikes,size(data,1)*32);
for i = 1:N_of_spikes
    sample =  data(:,detections(i)-15:detections(i)+16)';
    chained(i,:) = sample(:)';
end

end

