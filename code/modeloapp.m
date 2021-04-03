 function [vabc, iabcs, iabcr, fabcs, fabcr, tempo, torque, torquecarga, rot, psaida, pmedioentrada, pinstentrada, tsim] = modeloapp(parametro)
    clc
    tic;
    % Função que simula o modelo dinâmico de um motor de indução trifásico 
    fprintf('\n|-------------------------------------------------------------------------|\n');
    fprintf('|                            SIMULA.MIT                                   |\n');
    fprintf('|  Simulador de comportamento dinâmico de motores de indução trifásicos   |');
    fprintf('\n|-------------------------------------------------------------------------|\n\n');
    
    vn = parametro(1);              %Tensão nominal
    fr = parametro(2);              %Frequência nominal
    rs = parametro(3);              %Resistência do estator
    xls = parametro(4);             %Indutância de disperção do estator
    torquen = parametro(5);         %Torque nominal
    xm = parametro(6);              %Indutância mútua
    momj = parametro(7);            %Momento de inércia
    rr = parametro(8);              %Resistência do rotor
    xlr = parametro(9);             %Indutância de disperção do rotor
    polos = parametro(10);          %Número de polos
    acionamento = parametro(11);    %Tipo de acionamento (Senoidal, PWM ou SVPWM)   
    tmax = parametro(12);           %Tempo máximo de simulação
    p = parametro(13);              %Passo de simulação
    cr = parametro(14);             %Tipo de inserção de carga (Antes da partida, após a partida, gradativamente)
    pcarga = parametro(15)/100;     %Torque da carga (porcentagem do torque nominal)
        
    %% PARÂMETROS DO MOTOR
    
    fprintf('                       DADOS NOMINAIS DO MOTOR \n\n'); 
    fprintf('               Tesão ........................... %g V\n', vn);
    fprintf('               Frequência ...................... %g Hz\n', fr); 
    fprintf('               Torque .......................... %g N.m\n', torquen);
    fprintf('               Núm. de polos ................... %g\n', polos);
    fprintf('               Res. do estator ................. %g Ohm\n', rs);
    fprintf('               Res. do rotor ................... %g Ohm\n', rr);
    fprintf('               Mom. de inércia ................. %g Kg.m²\n', momj);
    fprintf('               Ind. mútua ...................... %g Ohm\n', xm);
    fprintf('               Ind. de disp.\n               do estator ...................... %g Ohm\n', xls);
    fprintf('               Ind. de disp.\n               do rotor ........................ %g Ohm\n', xlr);
    
    global wf we def mp ndados torquee torquec les ler lsr vds vqs vos ids iqs ios idr iqr ior
    
    %Globais
    mp = p/2;                  %Meio passo de amostragem
    ndados = round(tmax/p);    %Número de amostras
    pr = 1/fr;                 %periodo de rede/estator
    wf = 2*pi*fr;              %Frequência angular de rede/estator
    def = (2*pi)/3;            %Defasegem de 120° graus
    we = 0;                    %Definição da velocidade angular do eixo dq0
    
    %Motor
    vf = (vn*sqrt(2)/sqrt(3)); %Vmax de fase
    torquee = 0;               %Torque elétrico
    momj = (momj*2)/polos;     %Momento de inércia para n polos
    les = xls/wf;              %Indutância de dispersão do estator
    ler = xlr/wf;              %Indutância de dispersão do rotor
    lsr = xm/wf;               %Indutância mutua entre estator e rotor
    ls = les + lsr;            %Indutância de estator
    lr = ler + lsr;            %Indutâcia de rotor
    
    
    %% VARIÁVEIS
    
    %Auxiliares
    a = 1;                     %Auxiliar de contagem
    aux = (3/2)*(polos/2);     %Auxiliar de calculo
    aux2 = 120/(2*pi*polos);   %Auxiliar de conversão para RPM
    praux = 0;                 %Auxiliar de cálculo de potência (acréscimo de periodo)
    
    %Alocação de espaços para otimização
    teta = 0;                  %Ângulo de conversão dq0
    tetar = 0;                 %Ângulo de conversão dq0
    wr = 0;                    %Velocidade de rotação
    pe_ins = 0;                %Potência ativa instantanea de entrada
    pe = 0;                    %Potência ativa de entrada
    pmedio = 0;                %Potência ativa média de entrada;
    iqs = 0;
    ids = 0;
    ios = 0;
    iqr = 0;
    idr = 0;
    ior = 0;
    fqs = 0;
    fds = 0;
    fos = 0;
    fqr = 0;
    fdr = 0;
    foor = 0;
    vabc = zeros(ndados,3);
    vdqo = zeros(ndados,3);
    iabcr = zeros(ndados,3);
    iabcs = zeros(ndados,3);
    idqos = zeros(ndados,3);
    idqor = zeros(ndados,3);
    fabcs = zeros(ndados,3);
    fabcr = zeros(ndados,3);
    fdqos = zeros(ndados,3);
    fdqor = zeros(ndados,3);
    tempo = zeros(ndados,1);
    torque = zeros(ndados,1);
    torquecarga = zeros(ndados,1);
    rot = zeros(ndados,1);
    psaida = zeros(ndados,1);
    pmedioentrada = zeros(ndados,1);
    pinstentrada = zeros(ndados,1);
    
    %Matriz auxiliar para cálculo de correntes
    l = [(lr/(ls*lr - lsr^2)) (lsr/(ls*lr - lsr^2)) (ls/(ls*lr - lsr^2)) 1/les 1/ler];
    
    %Definindo tipo de onda
    if acionamento == 1
        vas_sen = vf*sin(wf*(0:p:tmax));
        vbs_sen = vf*sin(wf*(0:p:tmax) - def);
        vcs_sen = vf*sin(wf*(0:p:tmax) + def);
    elseif acionamento == 2
        [vas_pwm, vbs_pwm, vcs_pwm] = pwm_app(vf, tmax, p, 60, 2500);
    else
        [vas_svpwm, vbs_svpwm, vcs_svpwm] = svpwm_app(vf, tmax, p, 60, 2500);
    end     
    
    %% MODELO
    
    fprintf('\n---------------------------------------------------------------------------\n\n');
    fprintf('                        PARÂMETROS DE SIMULAÇÃO\n');
    fprintf('\n               Passo De Amostragem ............. %g [s]\n               Tempo Total Da Simulação ........ %g [s]\n', p, tmax);
    
    fprintf('\n---------------------------------------------------------------------------\n\n');
    fprintf('                               SIMULANDO\n');
    fprintf('                          Aguarde um instante\n');
    
    for t = 0:p:tmax
             
        pc = (100*t)/tmax;
        if pc == 20
            fprintf('         |::::::::::                                        | 20%%\n');
        elseif pc == 40
            fprintf('         |::::::::::::::::::::                              | 40%%\n');
        elseif pc == 60
            fprintf('         |::::::::::::::::::::::::::::::                    | 60%%\n');
        elseif pc == 80
            fprintf('         |::::::::::::::::::::::::::::::::::::::::          | 80%%\n');
        elseif pc == 100
            fprintf('         |::::::::::::::::::::::::::::::::::::::::::::::::::| 100%%\n');
        end
        
        %Inserção de carga para a partida do motor
        if cr == 1
            torquec = pcarga*torquen;
        elseif cr == 2
            if t < 0.5*tmax
                torquec = 0;
            else
                torquec = pcarga*torquen;
            end
        elseif cr == 3
            if t < 0.333*tmax
                torquec = 0;
            elseif t >= 0.333*tmax && t < 0.666*tmax
                torquec = 0.5*pcarga*torquen;
            else
                torquec = pcarga*torquen;
            end
        end
        
        %Definição das tensões de estator e conversão abc -> dq0
        if acionamento == 1
            vas = vas_sen(a);
            vbs = vbs_sen(a);
            vcs = vcs_sen(a);
            teta = teta + (we*p);
        elseif acionamento == 2
            vas = vas_pwm(a);
            vbs = vbs_pwm(a);
            vcs = vcs_pwm(a);
            teta = teta + (we*p);
        else
            vas = vas_svpwm(a);
            vbs = vbs_svpwm(a);
            vcs = vcs_svpwm(a);
            teta = teta + (we*p);
        end
        [vqs, vds, vos] = abc2qdo_app(vas, vbs, vcs, teta);
        
        %Runge-Kutta para estimação de estados
        estado = [fds, fqs, fos, fdr, fqr, foor, wr];
        k1 = rkutta_app(estado, momj, rr, rs);                                                                   %Estado 1
        k2 = rkutta_app(estado + k1*mp, momj, rr, rs);    %Estado 2
        k3 = rkutta_app(estado + k2*mp, momj, rr, rs);    %Estado 3
        k4 = rkutta_app(estado + k3*p, momj, rr, rs);     %Estado 4
        k = p*(k1 + 2*(k2 + k3) + k4)/6;                                                                                                %Estado final
        
        fds = fds + k(1);
        fqs = fqs + k(2);
        fos = fos + k(3);
        fdr = fdr + k(4);
        fqr = fqr + k(5);
        foor = foor + k(6);
        wr = wr + k(7);
        
        tetar = tetar + wr*p;
        tetart = teta - tetar;
        
        %Calculo das correntes de estator e rotor
        iqs = fqs*l(1) - fqr*l(2);
        ids = fds*l(1) - fdr*l(2);
        ios = fos*l(4);
        iqr = fqr*l(3) - fqs*l(2);
        idr = fdr*l(3) - fds*l(2);
        ior = foor*l(5);
        
        %Calculo do torque elétrico
        torquee = aux*(fds*iqs - fqs*ids);
        
        %Conversão das grandezas dq0 -> abc
        [ias, ibs, ics] = dqo2abc_app(iqs, ids, ios, teta);
        [iar, ibr, icr] = dqo2abc_app(iqr, idr, ior, tetart);
        [fas, fbs, fcs] = dqo2abc_app(fqs, fds, fos, teta);
        [far, fbr, fcr] = dqo2abc_app(fqr, fdr, foor, tetart); 
        
        %Cálculo da potência de entrada
        vab = vas - vbs;
        vbc = vbs - vcs;
        vca = vcs - vas;
        pe_ins_ant = pe_ins;
        pe_ins = vab*ias + vbc*ibs + vca*ics;
        pe = pe + (pe_ins + pe_ins_ant)*p;
        if t >= pr + praux
            praux = praux + pr;
            pmedio = pe / pr;
            pe = 0;
        end
        
        %Cálculo da potência de saída
        ps = torquee*wr/(polos/2);
        pin = ps + sqrt(2)*3*(ias^2 + iar^2);
                
        %Alocação de dados
        iabcs(a,1) = ias;
        iabcs(a,2) = ibs;
        iabcs(a,3) = ics;
        iabcr(a,1) = iar;
        iabcr(a,2) = ibr;
        iabcr(a,3) = icr;
        idqos(a,1) = ids;
        idqos(a,2) = iqs;
        idqos(a,3) = ios;
        idqor(a,1) = idr;
        idqor(a,2) = iqr;
        idqor(a,3) = ior;
        fabcs(a,1) = fas;
        fabcs(a,2) = fbs;
        fabcs(a,3) = fcs;
        fabcr(a,1) = far;
        fabcr(a,2) = fbr;
        fabcr(a,3) = fcr;
        fdqos(a,1) = fds;
        fdqos(a,2) = fqs;
        fdqos(a,3) = fos;
        fdqor(a,1) = fdr;
        fdqor(a,2) = fqr;
        fdqor(a,3) = foor;
        vabc(a,1) = vab;
        vabc(a,2) = vbs;
        vabc(a,3) = vcs;
        vdqo(a,1) = vds;
        vdqo(a,2) = vqs;
        vdqo(a,3) = vos; 
        tempo(a,1) = t;
        torque(a) = torquee;
        torquecarga(a) = torquec;
        pmedioentrada(a) = pin;
        %pmedioentrada(a) = pmedio;
        pinstentrada(a) = pe_ins;
        psaida(a) = ps;
        
        %Conversão da rotação rad/s -> rpm
        rot(a) = aux2*wr;
                    
        %Acrescimo no contador
        a = a + 1;     
        
    end
    
    avrtime = toc;
    tsim = avrtime;
    
    fprintf('                  O tempo de simulação foi %g [s]\n', avrtime);
    fprintf('\n---------------------------------------------------------------------------\n');
    fprintf('Aplicativo desenvolvido por João Pedro Carvalho Moreira(mcjpedro@gmail.com)\n');
    fprintf('   2020, Universidade Federal De São João Del Rei, Engenharia Elétrica');
    fprintf('\n---------------------------------------------------------------------------\n');
    
end