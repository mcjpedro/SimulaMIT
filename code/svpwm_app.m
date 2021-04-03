function [vas, vbs, vcs] = svpwm_app(vf, tmax, p, freq, ftri) 
    
    %Fun��o que simula a modula��o SVPWM de um inversor de frequ�ncia
    %[Tens�es de sa�da] = svpwm(Amplitude Da Tens�o De Fase De Entrada, Tempo M�ximo De Amostragem, Passo, Frequ�ncia Do Sinal De Entrada];

    fprintf('\n-----------------------------------------------------------------------------\n\n');
    fprintf('EXECUTANDO MODULA��O SVPWM\n');
    
    %% VARI�VEIS
    
    f = 60/freq;                    %Varia��es de frequ�ncia de entrada
    vf = vf/f;                      %Varia��es de frequ�ncia de entrada
    
    ts = 1/(2*ftri);                %Per�odo definido para a sequ�ncia de chaveamento (2500hz)
    wf = 2*pi*freq;                 %Velocidade angular do sinal de entrada
    vdc = 1.35*sqrt(3)*vf/sqrt(2);  %Tens�oo CC retificada
    vdc2 = vdc/2;                   %Tens�o CC retificada dividida por 2
     
    vr = 0.94933*vf;                %M�dulo do Vref - abs(vref)
    aux1 = (vr/vdc)*sqrt(3);        %Auxiliar para o c�lculo dos tempos de comuta��o 
    
    v0 = [0; 0; 0];                 %Chaveamento nulo v0
    v7 = [1; 1; 1];                 %Chaveamento nulo v7
    def = pi/3;                     %Auxliar de c�lculo (60�)
    def1 = 2*def;                   %Auxliar de c�lculo (120�)
    def2 = 3*def;                   %Auxliar de c�lculo (180�)
    def3 = 4*def;                   %Auxliar de c�lculo (220�)
    def4 = 5*def;                   %Auxliar de c�lculo (240�)
    aux2 = 2/3;                     %Auxliar de c�lculo
    aux3 = -0.50000 + 0.86603*1i;   %exp(i*2*pi/3)
    aux4 = -0.50000 - 0.86603*1i;   %exp(i*4*pi/3)
    cont = 1;                       %Contador 1
    tch = 0;                        %Tempo inicial para passo de chaveamento
    
    tempo = (0:p:tmax);
    vfase = zeros(length(tempo), 3);
    
    %% SIMULA��O

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
        
        % Definindo setor do vetor de refer�ncia 
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
        
        % Defini��o da sequ�ncia de chaveamento por per�odo
        if t >= tch
            % Posi��es das chaves para cada setor        
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
            
            % C�lculo do tempo de cada chaveamento        
            t1 = aux1*ts*sin(ch*def - teta);
            t2 = aux1*ts*sin(teta - (ch - 1)*def);
            t0 = (ts - t1 - t2);

            % Sequ�ncia temporal de chaveamento
            seqt1 = cumsum([t0/2, t1, t2, t0/2]); 
            seqt2 = cumsum([t0/2, t2, t1, t0/2]); 
            
            tch = t + ts*2;
            tch2 = t + ts;
        end
        
        % Defini��o da tens�o de sa�da para cada sequ�ncia de chaveamaneto        
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
    
    %% SA�DAS
    
    vas = vfase(:,1);
    vbs = vfase(:,2);
    vcs = vfase(:,3);

    
    
    
    
    
    
    
    
    
    
    
    
    