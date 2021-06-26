function [q_inv, t_inv] = qt_inv(q, t)
T = eye(4);
T(1:3,1:3) = quat2rotmat(q);
T(1:3,4) = t;
T_inv = inv(T);
q_inv = rotmat2quat(T_inv(1:3,1:3));
t_inv = T_inv(1:3,4);
end

