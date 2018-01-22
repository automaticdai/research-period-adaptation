close all;

fileRoot='./result_a/';  
  
list=dir(fullfile(fileRoot));  

fileNum = size(list,1)-2;  

yy = [];
uu = [];

%f = figure();

for k=3:fileNum
    fileName = list(k).name;
    filePath = strcat(fileRoot, fileName);
    load(filePath)
    
    yy = [yy; (ref.data - y.data)'];
    uu = [uu; u.data'];
end  

figure
image(yy .* 50)

figure
image(uu .* 20)


err = yy;
boxplot((err(1:100))')