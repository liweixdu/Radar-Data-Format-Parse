%% Introduction
%%% 1.�ó�������Ҫʵ���ܹ�����TI�����е��״����ݣ�Ŀǰ��֧��IWR16xx�Լ�IWR6843ϵ�е�DCA1000�ɼ������ݸ�ʽ
%%% 2.������ʽ����ĵ�swra581b������ĵ���ר�Ž������ݸ�ʽ�ģ�Ҳ�����׼��
%%% 3.��������������õ��Ľ��������ݽ�����Ե���ά�ȵ����ݶ��Եģ�Ҳ����˵����
%%%   ֻ�ܹ��õ�����ά��/ˮƽά�ȵ����ݣ����ܹ�ͬʱ�õ�ˮƽά�Ⱥ͸���ά�ȵ�����


%%% ===========PORT============
%%% ***********INPUT************
% numTx             ����ͨ����
% numRX             ����ͨ����
% numChan           ����ͨ����
% numADCSamples     ÿ��chirp�Ĳ�������
% numADCBits        ����ʱADC��λ��
% numChirps         chirp��
% numFrames         frames��
% isReal            ������������ʽ��1����ʵ������0��������
% radarType         �״������
%                   Ŀǰ��֧��ʹ��DCA1000EVM�忨�ɼ���IWR6843ϵ���Լ�IWR1642ϵ�е��״�����

%%% ***********OUTPUT************
% DataCube          ��������״����ݣ����ݸ�ʽ��(numADCSamples,numChan,numChirps,numFrames);
% numFrames         ��֡��

%% Function
function [DataCube,numFrames] = TIRadarDataParseFun(numTx,numRX,numADCSamples,numChirps,numADCBits,isReal,radarType)
numChan = numTx * numRX; 
%%% ��ȡ����������������
[filename,filepath] = uigetfile('*.bin');
str0 = [filepath,filename];
fid = fopen(str0,'rb+');
adcData = fread(fid, 'int16');  %% ע�⣬ԭʼ�����ǰ���int16�������
if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
end
fclose(fid);
fileSize = size(adcData, 1);
%%% ���ݽ���������
if isReal
    %%%% ʵ�����õ������ݽ��н���
    numFrames = fileSize/numADCSamples/numChan/numChirps;
    LVDS = adcData;
else
    %%%% �������õ������ݽ��н���
%     numAllChirps = fileSize/2/numADCSamples/numChan; %% ����2����Ϊ��IQ��·
    numFrames = fileSize/2/numADCSamples/numChan/numChirps; %% ����2����Ϊ��IQ��·
    LVDS = zeros(1, fileSize/2);    %%% ������ʽ��LVDS����
    %%% ���������ʽ����xWR16xx/IWR6843������ʽ�����ݸ�ʽ
    LVDS(1,1:2:fileSize/2) = adcData(1:4:fileSize)+ 1i*adcData(3:4:fileSize);
    LVDS(1,2:2:fileSize/2) = adcData(2:4:fileSize)+ 1i*adcData(4:4:fileSize);
end
adcDataCube = reshape(LVDS, numADCSamples,numChan,numChirps,numFrames);
DataCube = permute(adcDataCube,[1,3,2,4]);
% %% ��ͼ
% ��δ������Ϊ�򵥵�Debug
% figure
% plot(real(DataCube(:,:,1,1)),'r');
% hold on;
% plot(imag(DataCube(:,:,1,1)),'b');
% hold off;
% dataFFT = fft2(DataCube);
% figure;
% imagesc(abs(dataFFT(:,:,1,1)));


end

