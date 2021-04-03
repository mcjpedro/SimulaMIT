function [sfft,freq] = fourier_app(sinal,fs)
    
    %Função que transforma um sinal no domínio do tempo para o domínio da frequência
    %Entradas: sinal no domínio do tempo (sinal) e frequência de amostragem do sinal (fs = 1/passo)
    
    n = length(sinal);                  %Tamanho do vetor sinal
    k = 0:n-1;                          %Vetor auxiliar que vai de zero até n - 1  
    t = n/fs;                           %Vetor de tempo
    freq = k/t;                         %Vetor de frequência
    sfft = fftn(sinal)/n;               %FFT normalizada do vetor sinal sobre n
    cutOff = ceil(n/2);                 %Ajusta do eixo de sfft
    sfft = sfft(1:cutOff);
    plot(freq(1:cutOff),abs(sfft),'LineWidth', 2);     %Plota a transformada de Fourier e o valor de sfft em mÃ³dulo
    xlabel('Frequência (Hz)');
    ylabel('Amplitude');
    hold on

end 
