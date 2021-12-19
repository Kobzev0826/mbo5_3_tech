%% read file from GYRO 

fid = fopen('test_data_ADC.txt');

while ~feof(fid)
    tline = fgetl(fid);
    A=sscanf(tline,strcar())
end

fclose(fid);
% fileID = fopen('test_data_ADC.txt','r');
% sizeA = [1 Inf];
% [a,b,c,d] = sscanf()
% %A = fscanf(fileID,'%s\n', sizeA);
% fclose(fileID);