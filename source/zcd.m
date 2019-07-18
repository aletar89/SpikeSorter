function cross = zcd(samples, dir)
above = samples > 0;
shifted = [above(2:end), false];
if dir == "up"
    cross = ~above & shifted;
end
if dir =="down"
    cross = above & ~shifted;
end
end