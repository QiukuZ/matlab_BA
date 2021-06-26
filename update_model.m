function [imgs, points] = update_model(dx, imgs, points)
img_num = length(imgs);
point_num = length(points);
image_param_num = 6*img_num;
point_param_index = 3*point_num;

for i = 1:point_num
    point_param_index = image_param_num + (i-1) * 3 + 1;
    dxyz = dx(point_param_index: point_param_index + 2);
    point3D = points(i);
    point3D.xyz = point3D.xyz + dxyz;
    points(i) = point3D;
end

% image1 fixed
for i = 1:img_num
    img_param_index = (i-1) * 6 + 1;
    dpose = dx(img_param_index: img_param_index + 5);
    dR = expm([0, -dpose(3), dpose(2); dpose(3), 0, -dpose(1); -dpose(2), dpose(1), 0]);
    img = imgs(i);
    img.t = img.t + dpose(4:6);
    img.R = dR * img.R;
    imgs(i) = img;
end

end

