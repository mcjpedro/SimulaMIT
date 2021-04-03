function [sfft,freq] = fourier_app(sinal,fs)
    
    %Fun��o que transforma um sinal no dom�nio do tempo para o dom�nio da frequ�ncia
    %Entradas: sinal no dom�nio do tempo (sinal) e frequ�ncia de amostragem do sinal (fs = 1/passo)
    
    n = length(sinal);                  %Tamanho do vetor sinal
    k = 0:n-1;                          %Vetor auxiliar que vai de zero at� n - 1  
    t = n/fs;                           %Vetor de tempo
    freq = k/t;                         %Vetor de frequ�ncia
    sfft = fftn(sinal)/n;               %FFT normalizada do vetor sinal sobre n
    cutOff = ceil(n/2);                 %Ajusta do eixo de sfft
    sfft = sfft(1:cutOff);
    plot(freq(1:cutOff),abs(sfft),'LineWidth', 2);     %Plota a transformada de Fourier e o valor de sfft em módulo
    xlabel('Frequ�ncia (Hz)');
    ylabel('Amplitude');
    hold on

end 
