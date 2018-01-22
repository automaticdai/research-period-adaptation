% compile the kernel
mex -g ./core/kernel.cpp ./core/afbs.cpp ./core/app.cpp ./core/utils.cpp ...
       ./core/task.cpp

% addpath
addpath('./toolbox/')