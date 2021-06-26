function [] = write_model(path, cameras, images, points3D)

if ~exist(path)
    mkdir(path)
else
    rmdir(path,'s') 
    mkdir(path)
end
    
if numel(path) > 0 && path(end) ~= '/'
    path = [path '/'];
end

points3D_path = [path 'points3D.txt'];
image_path = [path 'images.txt'];
camera_path = [path 'cameras.txt'];

cam_num = length(cameras);
image_num = length(images);
point_num = length(points3D);

% Write camera txt
f_cam = fopen(camera_path, 'w');
fprintf(f_cam, '# Camera list with one line of data per camera:\n');
fprintf(f_cam, '#   CAMERA_ID, MODEL, WIDTH, HEIGHT, PARAMS[]\n');
fprintf(f_cam, '# Number of cameras: %d\n', cam_num);
for i = 1:cam_num
    fprintf(f_cam, '%d %s %d %d',i, cameras(i).model, cameras(i).width, cameras(i).height);
    for pai = 1:length(cameras(i).params)
        fprintf(f_cam, ' %f', cameras(1).params(pai));
    end
    fprintf(f_cam, '\n');
end
fclose(f_cam);

% Write image txt
f_image = fopen(image_path, 'w');
fprintf(f_image, '# Image list with two lines of data per image:\n');
fprintf(f_image, '#   IMAGE_ID, QW, QX, QY, QZ, TX, TY, TZ, CAMERA_ID, NAME\n');
fprintf(f_image, '#   POINTS2D[] as (X, Y, POINT3D_ID)\n');
fprintf(f_image, '# Number of images: %d, mean observations per image: 0\n', image_num);
for i = 1:image_num
    q = rotmat2quat(images(i).R);
    t = images(i).t;
    fprintf(f_image, '%d %f %f %f %f %f %f %f 1 a.png\n', i, q(1), q(2), q(3), q(4), t(1), t(2), t(3));
    for pi = 1:length(images(i).point3D_ids)
        fprintf(f_image, '%f %f %d ', images(i).xys(pi,1), images(i).xys(pi,2), images(i).point3D_ids(pi));
    end
    fprintf(f_image,'\n');
end
fclose(f_image);

% Write points txt
f_points = fopen(points3D_path, 'w');
fprintf(f_points, '# 3D point list with one line of data per point:\n');
fprintf(f_points, '#   POINT3D_ID, X, Y, Z, R, G, B, ERROR, TRACK[] as (IMAGE_ID, POINT2D_IDX)\n');
fprintf(f_points, '# Number of points: %d, mean track length: 0\n', point_num);
for i = 1:point_num
    fprintf(f_points, '%d %f %f %f %d %d %d 0', i, points3D(i).xyz(1), points3D(i).xyz(2), points3D(i).xyz(3), points3D(i).rgb(1), points3D(i).rgb(1), points3D(i).rgb(1));
    for ti = 1:size(points3D(i).track,1)
        fprintf(f_points, ' %d %d',points3D(i).track(ti,1), points3D(i).track(ti,2)-1);
    end
    fprintf(f_points, '\n');
end
fclose(f_points);
end

