function [cameras, images, points3D, cameras_gt, images_gt, points3D_gt] = generate_model(image_num, point_num)

cameras = containers.Map('KeyType', 'int64', 'ValueType', 'any');
images = containers.Map('KeyType', 'int64', 'ValueType', 'any');
points3D = containers.Map('KeyType', 'int64', 'ValueType', 'any');

cameras_gt = containers.Map('KeyType', 'int64', 'ValueType', 'any');
images_gt = containers.Map('KeyType', 'int64', 'ValueType', 'any');
points3D_gt = containers.Map('KeyType', 'int64', 'ValueType', 'any');


% Config 
camera_num = 1;

cam_width = 640;
cam_height = 480;
fx = 1000.0;
fy = 1000.0;
cx = 320.0;
cy = 240.0;
K = [fx, 0, cx;0, fy, cy;0, 0, 1];

for i = 1:camera_num
    camera = struct;
    camera.camera_id = 1;
    camera.model = 'PINHOLE';
    camera.width = cam_width;
    camera.height = cam_height;
    camera.params(1) = fx;
    camera.params(2) = fy;
    camera.params(3) = cx;
    camera.params(4) = cy;
    cameras(camera.camera_id) = camera;
    cameras_gt(camera.camera_id) = camera;
end

% Generate fake points
% randon_points = randn(3,point_num);
randon_points = generate_sphere(1, point_num);
randon_rgbs = unidrnd(255,3,point_num);

x = randon_points(1,:);
y = randon_points(2,:);
z = randon_points(3,:);
randon_rgbs(1,:) = mod(round(abs(x*80)),255);
randon_rgbs(2,:) = mod(round(abs(y*80)),255);
randon_rgbs(3,:) = mod(round(abs(z*80)),255);

% Set Image Pose
% q and t = world to cam
qs = zeros(20,4);
ts = zeros(20,3);
radius = 10;
dpi = 2*pi/image_num;
points_track = cell(point_num,1);

% note : in colmap , image's pose saved as from world to cam
for i = 1:image_num
    theta = -pi + i*dpi;
    t = [radius * cos(theta),0,radius * sin(theta)];
    R = angle2dcm(0,theta+pi/2,0);
    q = rotmat2quat(R);
    [qs(i,:), ts(i,:)] = qt_inv(q,t);
    image = struct;
    image.image_id = i;
    image.R = quat2rotmat(qs(i,:));
    image.t = ts(i,:)';
    image.name = [num2str(i), '.png'];
    image.camera_id = 1;
    
    points_cam = image.R*randon_points + repmat(image.t,[1,point_num]);
    KP = K * points_cam;
    uv = KP(1:2,:) ./ points_cam(3,:);
    
    black = zeros(cam_height, cam_width, 3);
    xys = [];
    point3D_ids = [];
    
    for poi = 1:point_num
        if KP(3,i) > 0
            if 0 < uv(1,poi) && uv(1,poi) < cam_width && 0 < uv(2,poi) && uv(2,poi) < cam_height
                xys_i = uv(:,poi)' + randn(1,2);
                xys = [xys; xys_i];
                point3D_ids = [point3D_ids; poi];
                points_track{poi} = [points_track{poi}; [i, size(xys,1)]]; 
            end 
        end
    end
    
    image.xys = xys;
    image.point3D_ids = point3D_ids;
    images_gt(image.image_id) = image;
    % Add Noise [ image-1 fix]
    if ~(image.image_id == 0)
        image.R = angle2dcm(0.2*randn(), 0.2*randn(), 0.2*randn()) * image.R;
        image.t = image.t + 3*randn(3,1);
    end
    images(image.image_id) = image;
end


for i = 1:point_num
    point = struct;
    point.point3D_id = i;
    point.xyz = randon_points(:,i);
    point.rgb = randon_rgbs(:,i);
    point.error = 100.0;
    point.track = points_track{i};
    points3D_gt(point.point3D_id) = point;
    % Add point Noise 
    point.xyz = point.xyz + 0.2 * randn(3,1);
    points3D(point.point3D_id) = point;
end
end

