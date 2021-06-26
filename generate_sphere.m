function [points] = generate_sphere(r, point_num)

rand_num = 1000;
dpi = 2*pi/rand_num;
points = zeros(3,point_num);

for i = 1:point_num
    theta = unidrnd(rand_num)*dpi;
    phi = unidrnd(rand_num)*dpi;
    points(1,i) = r * sin(theta) * cos(phi);
    points(2,i) = r * sin(theta) * sin(phi);
    points(3,i) = r * cos(theta);
end

end