function qvec = rotmat2quat(R)

q = dcm2quat(R);
qvec = -q;
qvec(1) = -qvec(1);

end