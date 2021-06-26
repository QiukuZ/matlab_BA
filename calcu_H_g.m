function [H,g,error_mean] = calcu_H_g(cameras, images, points3D)

fx = cameras(1).params(1);
fy = cameras(1).params(2);
cx = cameras(1).params(3);
cy = cameras(1).params(4);
K = [cameras(1).params(1),0,cameras(1).params(3);0,cameras(1).params(2),cameras(1).params(4);0,0,1];

point_num = length(points3D);
image_num = length(images);

% param_num =  6 x pose_num + 3 x point_num
image_param_num = 6 * image_num;
point_param_num = 3 * point_num;
optim_param_num = image_param_num + point_param_num;

obs_num = 0;
for i = 1:point_num
    obs_num = obs_num + size(points3D(i).track,1);
end

% fprintf('obs_num = %d \n', obs_num);
Jacobian = zeros(obs_num, optim_param_num);

index = 0;
error_sum = 0;
errors = [];
for i = 1:point_num
    for j = 1:size(points3D(i).track,1)
        index = index + 1;
        point = points3D(i).xyz;
        image_id = points3D(i).track(j,1);
        uv_obs = images(image_id).xys(points3D(i).track(j,2),:);
        R = images(image_id).R;
        t = images(image_id).t;
        point_cam = R * point + t;
        uv_rep = K * point_cam ./ point_cam(3);
        uv_rep = uv_rep(1:2)';
        error_uv = uv_rep - uv_obs;
        
        error = sum(error_uv.*error_uv);
        errors = [errors;error];
        error_sum = error_sum + error;
        
        partial_uv_to_pcam = [fx/point_cam(3),0,-fx*point_cam(1)/(point_cam(3)*point_cam(3));0,fy/point_cam(3),-fy*point_cam(2)/(point_cam(3)*point_cam(3))];
        partial_e_to_pcam = error_uv * partial_uv_to_pcam;
        Rp = R * point;
        partial_pcam_to_R = - [0,-Rp(3),Rp(2); Rp(3),0,-Rp(1);-Rp(2), Rp(1),0];
        % calcu image jacobian
        jacobian_image = zeros(1,6);
        jacobian_image(1:3) = partial_e_to_pcam * partial_pcam_to_R;
        jacobian_image(4:6) = partial_e_to_pcam;
        image_param_index = (image_id - 1) * 6 + 1;
        Jacobian(index, image_param_index:image_param_index+5) = Jacobian(index, image_param_index:image_param_index+5) + jacobian_image;
        
        % calcu point jacobian
        jacobian_point = partial_e_to_pcam * R;
        point_param_index = image_param_num + (i-1) * 3 + 1;
        Jacobian(index, point_param_index:point_param_index+2) = Jacobian(index, point_param_index:point_param_index+2) + jacobian_point;
    end
end

H = Jacobian' * Jacobian;
g = - Jacobian' * errors;
error_mean = 0.5 * error_sum;
end

