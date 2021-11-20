%% Introduction
%%% 1.该程序最终要实现能够解析TI的所有的雷达数据，目前仅支持IWR16xx以及IWR6843系列的DCA1000采集的数据格式
%%% 2.解析格式详见文档swra581b，这个文档是专门讲解数据格式的，也是最标准的
%%% 3.这个解析程序所得到的解析的数据仅仅针对单个维度的数据而言的，也就是说最终
%%%   只能够得到俯仰维度/水平维度的数据，不能够同时得到水平维度和俯仰维度的数据


%%% ===========PORT============
%%% ***********INPUT************
% numTx             发射通道数
% numRX             接收通道数
% numChan           虚拟通道数
% numADCSamples     每个chirp的采样点数
% numADCBits        采样时ADC的位数
% numChirps         chirp数
% numFrames         frames数
% isReal            采样的数据形式：1代表实采样，0代表复采样
% radarType         雷达的种类
%                   目前仅支持使用DCA1000EVM板卡采集的IWR6843系列以及IWR1642系列的雷达数据

%%% ***********OUTPUT************
% DataCube          解析后的雷达数据，数据格式是(numADCSamples,numChan,numChirps,numFrames);
% numFrames         总帧数

%% Function
function [DataCube,numFrames] = TIRadarDataParseFun(numTx,numRX,numADCSamples,numChirps,numADCBits,isReal,radarType)
numChan = numTx * numRX; 
%%% 读取并解析二进制数据
[filename,filepath] = uigetfile('*.bin');
str0 = [filepath,filename];
fid = fopen(str0,'rb+');
adcData = fread(fid, 'int16');  %% 注意，原始数据是按照int16来保存的
if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
end
fclose(fid);
fileSize = size(adcData, 1);
%%% 数据解析与重组
if isReal
    %%%% 实采样得到的数据进行解析
    numFrames = fileSize/numADCSamples/numChan/numChirps;
    LVDS = adcData;
else
    %%%% 复采样得到的数据进行解析
%     numAllChirps = fileSize/2/numADCSamples/numChan; %% 除以2是因为有IQ两路
    numFrames = fileSize/2/numADCSamples/numChan/numChirps; %% 除以2是因为有IQ两路
    LVDS = zeros(1, fileSize/2);    %%% 复数形式的LVDS数组
    %%% 下面这个格式符合xWR16xx/IWR6843复数形式的数据格式
    LVDS(1,1:2:fileSize/2) = adcData(1:4:fileSize)+ 1i*adcData(3:4:fileSize);
    LVDS(1,2:2:fileSize/2) = adcData(2:4:fileSize)+ 1i*adcData(4:4:fileSize);
end
adcDataCube = reshape(LVDS, numADCSamples,numChan,numChirps,numFrames);
DataCube = permute(adcDataCube,[1,3,2,4]);
% %% 绘图
% 这段代码可作为简单的Debug
% figure
% plot(real(DataCube(:,:,1,1)),'r');
% hold on;
% plot(imag(DataCube(:,:,1,1)),'b');
% hold off;
% dataFFT = fft2(DataCube);
% figure;
% imagesc(abs(dataFFT(:,:,1,1)));


end

