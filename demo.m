clear all;
clc;

% Config 
model_path = 'model';
is_write_model = 0;
is_write_gt_model = 0;

% generate model 
[cameras, images, points3D, cameras_gt, images_gt, points3D_gt] = generate_model(20,500);

% write_model('model/test', cameras, images, points3D);
% [cameras_read, images_read, points3D_read] = read_model('model/test');

% BA optim

for i = 1:6
    
    % save model for every iter
    if is_write_model
        write_model([model_path '/iter' num2str(i-1)], cameras, images, points3D);
    end
    
    % GN iter optim
    tic;
    [H,g,e] = calcu_H_g(cameras, images, points3D);
    fprintf('iter %d : error = %6g , error_mean = %6f ', i, e , sqrt(e/residuals_num));
    H = H + 10000*eye(size(H,1));
    dx = inv(H) * g;
    [images, points3D] = update_model(dx, images, points3D);
    toc;
    
end

% save gt model
if is_write_gt_model
    write_model([model_path '/gt_model'], cameras_gt, images_gt, points3D_gt);
end

% save final model
if is_write_model
    write_model([model_path '/final_model'], cameras, images, points3D);
end
