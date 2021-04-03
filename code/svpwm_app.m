function [vas, vbs, vcs] = svpwm_app(vf, tmax, p, freq, ftri) 
    
    %Função que simula a modulação SVPWM de um inversor de frequência
    %[Tensões de saída] = svpwm(Amplitude Da Tensão De Fase De Entrada, Tempo Máximo De Amostragem, Passo, Frequência Do Sinal De Entrada];

    fprintf('\n-----------------------------------------------------------------------------\n\n');
    fprintf('EXECUTANDO MODULAÇÃO SVPWM\n');
    
    %% VARIÁVEIS
    
    f = 60/freq;                    %Variações de frequência de entrada
    vf = vf/f;                      %Variações de frequência de entrada
    
    ts = 1/(2*ftri);                %Período definido para a sequência de chaveamento (2500hz)
    wf = 2*pi*freq;                 %Velocidade angular do sinal de entrada
    vdc = 1.35*sqrt(3)*vf/sqrt(2);  %Tensãoo CC retificada
    vdc2 = vdc/2;                   %Tensão CC retificada dividida por 2
     
    vr = 0.94933*vf;                %Módulo do Vref - abs(vref)
    aux1 = (vr/vdc)*sqrt(3);        %Auxiliar para o cálculo dos tempos de comutação 
    
    v0 = [0; 0; 0];                 %Chaveamento nulo v0
    v7 = [1; 1; 1];                 %Chaveamento nulo v7
    def = pi/3;                     %Auxliar de cálculo (60°)
    def1 = 2*def;                   %Auxliar de cálculo (120°)
    def2 = 3*def;                   %Auxliar de cálculo (180°)
    def3 = 4*def;                   %Auxliar de cálculo (220°)
    def4 = 5*def;                   %Auxliar de cálculo (240°)
    aux2 = 2/3;                     %Auxliar de cálculo
    aux3 = -0.50000 + 0.86603*1i;   %exp(i*2*pi/3)
    aux4 = -0.50000 - 0.86603*1i;   %exp(i*4*pi/3)
    cont = 1;                       %Contador 1
    tch = 0;                        %Tempo inicial para passo de chaveamento
    
    tempo = (0:p:tmax);
    vfase = zeros(length(tempo), 3);
    
    %% SIMULAÇÃO

    for t = tempo
        
        % Gerando Ondas senoidais
        vfa = vf*sin(wf*t);
        vfb = vf*sin(wf*t - 2*def);
        vfc = vf*sin(wf*t - 4*def);
        
        vref = aux2*(vfa + vfb*aux3 + vfc*aux4);
        teta = atan2(imag(vref), real(vref));
        
        if teta < 0 
            teta = 2*pi + teta;
        end
        
        % Definindo setor do vetor de referência 
        if teta >= 0 && teta < def
            ch = 1;
        elseif teta >= def && teta < def1
            ch = 2;
        elseif teta >= def1 && teta < def2
            ch = 3;
        elseif teta >= def2 && teta < def3
            ch = 4;
        elseif teta >= def3 && teta < def4
            ch = 5;
        else
            ch = 6;
        end
        
        % Definição da sequência de chaveamento por período
        if t >= tch
            % Posições das chaves para cada setor        
            if ch == 1
                v1=[1 ;0 ;0];  
                v2=[1 ;1 ;0]; 
            elseif ch == 2
                v1=[1; 1; 0]; 
                v2=[0; 1; 0];
            elseif ch == 3
                v1=[0; 1; 0];  
                v2=[0; 1; 1];
            elseif ch == 4
                v1=[0; 1; 1]; 
                v2=[0; 0; 1]; 
            elseif ch == 5
                v1=[0; 0; 1];  
                v2=[1; 0; 1];
            else
                v1=[1; 0; 1];  
                v2=[1; 0; 0];
            end
            
            % Cálculo do tempo de cada chaveamento        
            t1 = aux1*ts*sin(ch*def - teta);
            t2 = aux1*ts*sin(teta - (ch - 1)*def);
            t0 = (ts - t1 - t2);

            % Sequência temporal de chaveamento
            seqt1 = cumsum([t0/2, t1, t2, t0/2]); 
            seqt2 = cumsum([t0/2, t2, t1, t0/2]); 
            
            tch = t + ts*2;
            tch2 = t + ts;
        end
        
        % Definição da tensão de saída para cada sequência de chaveamaneto        
        if t <= tch2
            if t <= (tch2 - ts) + seqt1(1)
                s = v0;
            elseif t <= (tch2 - ts) + seqt1(2)
                s = v1;
            elseif t <= (tch2 - ts) + seqt1(3)
                s = v2;
            elseif t <= tch2
                s = v7;
            end
        else
            if t <= tch2 + seqt2(1)
                s = v7;
            elseif t <= tch2 + seqt2(2)
                s = v2;
            elseif t <= tch2 + seqt2(3)
                s = v1;
            elseif t <= tch
                s = v0;
            end
        end
        
        if s(1) == 1 && s(2) == 1 && s(3) == 1
            vpwma = vdc2;
            vpwmb = vdc2;
            vpwmc = vdc2;
        elseif s(1) == 0 && s(2) == 0 && s(3) == 0
            vpwma = vdc2;
            vpwmb = vdc2;
            vpwmc = vdc2;            
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

    
    
    
    
    
    
    
    
    
    
    
    
    