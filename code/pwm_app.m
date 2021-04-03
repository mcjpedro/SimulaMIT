function [vas, vbs, vcs] = pwm_app(vf, tmax, p, freq, ftri) 

    %Função que simula a modulação PWM de um inversor de frequência
    %[Tensões de saída] = pwm(Amplitude Da Tensão De Fase De Entrada, Tempo Máximo De Amostragem, Passo, Frequência Do Sinal De Entrada, Frequência Do Sinal Triangular];
    
    fprintf('\n-----------------------------------------------------------------------------\n\n');
    fprintf('EXECUTANDO MODULAÇÃO PWM\n');
    
    %% VARIÁVEIS
    
    f = 60/freq;                               %Variações de frequência de entrada
    vf = vf/f;                                 %Variações de frequência de entrada
    
    vdc = 1.35*sqrt(3)*vf/sqrt(2);             %Tensãoo CC retificada
    vdc2 = vdc/2;                              %Tensãoo CC retificada dividida por 2
    wtri = ftri*2*pi;                          %Frequência angular da onda de comparação
    wf = freq*2*pi;                            %Frequência angular da rede
    
    def = (2*pi)/3;                            %Defasagem de 120°
    cont = 1;
    tempo = (0:p:tmax);
    vfase = zeros(length(tempo),3);
    
    %Variáveis opicionais
    %wf1 = wf/2;                                %Redução do sinal de entrada para 30Hz
    %v1 = v/2;                                  %Redução do sinal de entrada para 30Hz


    %% SIMULAÇÃO
    
    %Criação das ondas portadora e moduladoras
    tri = vdc2*sawtooth(wtri*tempo,0.5);                
    vaf = vf*sin(wf*tempo);         % + 1/3*vf*sin(3*wf*tempo);
    vbf = vf*sin(wf*tempo - def);   % + 1/3*vf*sin(3*wf*tempo);
    vcf = vf*sin(wf*tempo + def);   % + 1/3*vf*sin(3*wf*tempo);
        
    %Comparação entre onda portadora e ondas modulaoras
    sa(vaf >= tri) = 1;
    sa(vaf < tri) = 0;
    sb(vbf >= tri) = 1;
    sb(vbf < tri) = 0;
    sc(vcf >= tri) = 1;
    sc(vcf < tri) = 0;
    sabc = [sa; sb; sc];
    
    for t = tempo
        s = sabc(:,cont);
        % Definição da tensão de saída para cada sequência de chaveamaneto    
        if s(1) == 1 && s(2) == 1 && s(3) == 1
            vpwma = vdc2;
            vpwmb = vdc2;
            vpwmc = vdc2;
        elseif s(1) == 0 && s(2) == 0 && s(3) == 0
            vpwma = -vdc2;
            vpwmb = -vdc2;
            vpwmc = -vdc2;
        elseif s(1) == 1 && s(2) == 1 && s(3) == 0
            vpwma = vdc2;
            vpwmb = vdc2;
            vpwmc = -vdc2;
        elseif s(1) == 1 && s(2) == 0 && s(3) == 1
            vpwma = vdc2;
            vpwmb = -vdc2;
            vpwmc = vdc2;
        elseif s(1) == 0 && s(2) == 1 && s(3) == 1
            vpwma = -vdc2;
            vpwmb = vdc2;
            vpwmc = vdc2;
        elseif s(1) == 0 && s(2) == 0 && s(3) == 1
            vpwma = -vdc2;
            vpwmb = -vdc2;
            vpwmc = vdc2; 
        elseif s(1) == 0 && s(2) == 1 && s(3) == 0
            vpwma = -vdc2;
            vpwmb = vdc2;
            vpwmc = -vdc2; 
        elseif s(1) == 1 && s(2) == 0 && s(3) == 0
            vpwma = vdc2;
            vpwmb = -vdc2;
            vpwmc = -vdc2;
        end

        vfase(cont,:) = 0.333*[2, -1, -1; -1, 2, -1; -1, -1, 2]*[vpwma; vpwmb; vpwmc];
        cont = cont + 1;
    end 
    
    %% SAÍDAS
    
    vas = vfase(:,1);
    vbs = vfase(:,2);
    vcs = vfase(:,3);