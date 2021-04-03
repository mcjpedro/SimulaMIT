function [vas, vbs, vcs] = pwm_app(vf, tmax, p, freq, ftri) 

    %Fun��o que simula a modula��o PWM de um inversor de frequ�ncia
    %[Tens�es de sa�da] = pwm(Amplitude Da Tens�o De Fase De Entrada, Tempo M�ximo De Amostragem, Passo, Frequ�ncia Do Sinal De Entrada, Frequ�ncia Do Sinal Triangular];
    
    fprintf('\n-----------------------------------------------------------------------------\n\n');
    fprintf('EXECUTANDO MODULA��O PWM\n');
    
    %% VARI�VEIS
    
    f = 60/freq;                               %Varia��es de frequ�ncia de entrada
    vf = vf/f;                                 %Varia��es de frequ�ncia de entrada
    
    vdc = 1.35*sqrt(3)*vf/sqrt(2);             %Tens�oo CC retificada
    vdc2 = vdc/2;                              %Tens�oo CC retificada dividida por 2
    wtri = ftri*2*pi;                          %Frequ�ncia angular da onda de compara��o
    wf = freq*2*pi;                            %Frequ�ncia angular da rede
    
    def = (2*pi)/3;                            %Defasagem de 120�
    cont = 1;
    tempo = (0:p:tmax);
    vfase = zeros(length(tempo),3);
    
    %Vari�veis opicionais
    %wf1 = wf/2;                                %Redu��o do sinal de entrada para 30Hz
    %v1 = v/2;                                  %Redu��o do sinal de entrada para 30Hz


    %% SIMULA��O
    
    %Cria��o das ondas portadora e moduladoras
    tri = vdc2*sawtooth(wtri*tempo,0.5);                
    vaf = vf*sin(wf*tempo);         % + 1/3*vf*sin(3*wf*tempo);
    vbf = vf*sin(wf*tempo - def);   % + 1/3*vf*sin(3*wf*tempo);
    vcf = vf*sin(wf*tempo + def);   % + 1/3*vf*sin(3*wf*tempo);
        
    %Compara��o entre onda portadora e ondas modulaoras
    sa(vaf >= tri) = 1;
    sa(vaf < tri) = 0;
    sb(vbf >= tri) = 1;
    sb(vbf < tri) = 0;
    sc(vcf >= tri) = 1;
    sc(vcf < tri) = 0;
    sabc = [sa; sb; sc];
    
    for t = tempo
        s = sabc(:,cont);
        % Defini��o da tens�o de sa�da para cada sequ�ncia de chaveamaneto    
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
    
    %% SA�DAS
    
    vas = vfase(:,1);
    vbs = vfase(:,2);
    vcs = vfase(:,3);