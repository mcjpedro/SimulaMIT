 function [] = graficoapp(vabc, iabcs, iabcr, fabcs, fabcr, tempo, torque, torquecarga, rot, psaida, pmedioentrada, pinstentrada, op) 
    
    % Fun��o que plota os gr�ficos de um mit
    % Op��es de gr�ficos:
    %      1) Tens�o de entrada
    %      2) Correntes (abc)   
    %      3) Fluxo (abc)  
    %      4) Torque eletromagn�tico 
    %      5) Torque da carga   
    %      6) Torque x Velocidade 
    %      7) Velocidade     
    %      8) Corrente de entrada no dom�nio da frequ�ncia 
    %      9) Tens�o de entrada no dom�nio da frequ�ncia  
    %      10) Pot�ncia ativa instant�nea de entrada  
    %      11) Pot�ncia m�dia de entrada
    %      12) Potencia de sa�da
    %      13) Todos
    
       
    ntempo = length(tempo);
    tmax = tempo(ntempo);
    p = tempo(2) - tempo(1);
    
    grafico = zeros(1,13);
    n = length(op);
    for a = 1:13
        for b = 1:n
            if a == op(b)
                grafico(a) = op(b);
            end
        end
    end
    
    %% GR�FICOS
    if grafico(1) == 1 || grafico(13) == 13
        %Gr�ficos de corrente abc
        figure(1);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,vabc(:,1),'LineWidth', 2);
        title('Tens�o De Estator Vas');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Tens�o [V]'); 
        grid on
        hold on
    end
    
    if grafico(2) == 2 || grafico(13) == 13
        %Gr�ficos de corrente abc
        figure(2);
        set(gcf,'color',[0.6 0.7 0.8])
        subplot(2,1,1);
        plot(tempo,iabcs(:,1),'LineWidth', 2);
        title('Corrente De Estator Ias');
        xlim([0 tmax]);    
        xlabel('Tempo [s]'); 
        ylabel('Corrente [A]'); 
        grid on
        subplot(2,1,2);
        plot(tempo,iabcr(:,1),'LineWidth', 2);
        title('Corrente De Rotor Iar'); 
        xlim([0 tmax]);  
        xlabel('Tempo [s]'); 
        ylabel('Corrente [A]');
        grid on
        hold on
    end
    
    if grafico(3) == 3 || grafico(13) == 13
        %Gr�ficos de fluxo abc
        figure(3);
        set(gcf,'color',[0.6 0.7 0.8])
        subplot(2,1,1);
        plot(tempo, fabcs(:,1),'LineWidth', 2);
        xlim([0 tmax]);
        title('Fluxo De Estator Fas','fontsize',14);
        xlabel('Tempo [s]','fontsize',14); 
        ylabel('Fluxo [Wb]','fontsize',14);   
        grid on
        subplot(2,1,2);
        plot(tempo, fabcr(:,1),'LineWidth', 2);
        title('Fluxo De Rotor Far','fontsize',14);
        xlim([0 tmax]);
        xlabel('Tempo [s]','fontsize',14); 
        ylabel('Fluxo [Wb]','fontsize',14);   
        grid on
        hold on
    end
    
    if grafico(4) == 4 || grafico(13) == 13
        %Gr�fico de torque eletromagn�tico
        figure(4);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,torque,'LineWidth', 1);
        title('Torque Eletromagn�tico');
        xlabel('Tempo [s]'); 
        ylabel('Torque [Nm]');
        xlim([0 tmax]);   
        grid on
        hold on
    end
    
    if grafico(5) == 5 || grafico(13) == 13
        %Gr�fico de torque da carga
        figure(5);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,torquecarga,'LineWidth', 2);
        title('Torque De Carga');
        xlabel('Tempo [s]'); 
        ylabel('Torque [Nm]');
        xlim([0 tmax]);
        grid on
        hold on
    end
    
    if grafico(6) == 6 || grafico(13) == 13
        %Gr�fico de torque eletromagn�tico em fun��o da velocidade
        figure(6);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(rot,torque,'LineWidth', 2);
        title('Torque Eletromagn�tico Em Fun��o Da Velocidade');
        xlabel('Velocidade [rpm]'); 
        ylabel('Torque [Nm]');   
        grid on
        hold on
    end
    
    if grafico(7) == 7 || grafico(13) == 13
        %Gr�fico de velocidade
        figure(7);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,rot,'LineWidth', 2);
        title('Velocidade');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Velocidade [rpm]');   
        grid on
        hold on
    end
    
    if grafico(8) == 8 || grafico(13) == 13
        %Gr�fico de frequ�ncia da corente de entrada
        figure(8);
        set(gcf,'color',[0.6 0.7 0.8])
        iabcs_per = iabcs((0.8*length(iabcs):length(iabcs)),1); %Cortando apenas a corrente em regime permanente   
        fourier_app(iabcs_per, 1/p);                            %Aplica��o da FFT
        title('Transformada R�pida de Fourier (FFT) Da Corrente De Estator'); 
    end
    
    if grafico(9) == 9 || grafico(13) == 13
        %Gr�fico de frequ�ncia da tens�o de entrada
        figure(9);
        set(gcf,'color',[0.6 0.7 0.8])
        fourier_app(vabc(:,1),1/p);                      %Aplica��o da FFT
        title('Transformada R�pida de Fourier (FFT) Da Tens�o de Entrada');
    end
    
    if grafico(10) == 10 || grafico(13) == 13
        %Gr�fico de pot�ncia ativa instant�nea de entrada
        figure(10);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,pinstentrada,'LineWidth', 2);
        title('Pot�ncia Ativa Isntant�nea De Entrada');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Pot�ncia [W]');    
        grid on
        hold on
    end
    
    if grafico(11) == 11 || grafico(13) == 13
        %Gr�fico de pot�ncia ativa m�dia de entrada
        figure(11);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,pmedioentrada,'LineWidth', 2);
        title('Pot�ncia Ativa M�dia De Entrada');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Pot�ncia [W]');    
        grid on
        hold on
    end  
    
    if grafico(12) == 12 || grafico(13) == 13
        %Gr�fico de pot�ncia ativa de sa�da
        figure(12);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,psaida,'LineWidth', 2);
        title('Pot�ncia Ativa'); %Instant�nea');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Pot�ncia [W]');  
        grid on
        hold on
%         plot(tempo,pinstentrada,'LineWidth', 2)
%         hold on
%         plot(tempo,pmedioentrada,'LineWidth', 2)
    end 
end    