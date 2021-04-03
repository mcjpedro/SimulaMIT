 function [] = graficoapp(vabc, iabcs, iabcr, fabcs, fabcr, tempo, torque, torquecarga, rot, psaida, pmedioentrada, pinstentrada, op) 
    
    % Função que plota os gráficos de um mit
    % Opções de gráficos:
    %      1) Tensão de entrada
    %      2) Correntes (abc)   
    %      3) Fluxo (abc)  
    %      4) Torque eletromagnético 
    %      5) Torque da carga   
    %      6) Torque x Velocidade 
    %      7) Velocidade     
    %      8) Corrente de entrada no domínio da frequência 
    %      9) Tensão de entrada no domínio da frequência  
    %      10) Potência ativa instantânea de entrada  
    %      11) Potência média de entrada
    %      12) Potencia de saída
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
    
    %% GRÁFICOS
    if grafico(1) == 1 || grafico(13) == 13
        %Gráficos de corrente abc
        figure(1);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,vabc(:,1),'LineWidth', 2);
        title('Tensão De Estator Vas');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Tensão [V]'); 
        grid on
        hold on
    end
    
    if grafico(2) == 2 || grafico(13) == 13
        %Gráficos de corrente abc
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
        %Gráficos de fluxo abc
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
        %Gráfico de torque eletromagnético
        figure(4);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,torque,'LineWidth', 1);
        title('Torque Eletromagnético');
        xlabel('Tempo [s]'); 
        ylabel('Torque [Nm]');
        xlim([0 tmax]);   
        grid on
        hold on
    end
    
    if grafico(5) == 5 || grafico(13) == 13
        %Gráfico de torque da carga
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
        %Gráfico de torque eletromagnético em função da velocidade
        figure(6);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(rot,torque,'LineWidth', 2);
        title('Torque Eletromagnético Em Função Da Velocidade');
        xlabel('Velocidade [rpm]'); 
        ylabel('Torque [Nm]');   
        grid on
        hold on
    end
    
    if grafico(7) == 7 || grafico(13) == 13
        %Gráfico de velocidade
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
        %Gráfico de frequência da corente de entrada
        figure(8);
        set(gcf,'color',[0.6 0.7 0.8])
        iabcs_per = iabcs((0.8*length(iabcs):length(iabcs)),1); %Cortando apenas a corrente em regime permanente   
        fourier_app(iabcs_per, 1/p);                            %Aplicação da FFT
        title('Transformada Rápida de Fourier (FFT) Da Corrente De Estator'); 
    end
    
    if grafico(9) == 9 || grafico(13) == 13
        %Gráfico de frequência da tensão de entrada
        figure(9);
        set(gcf,'color',[0.6 0.7 0.8])
        fourier_app(vabc(:,1),1/p);                      %Aplicação da FFT
        title('Transformada Rápida de Fourier (FFT) Da Tensão de Entrada');
    end
    
    if grafico(10) == 10 || grafico(13) == 13
        %Gráfico de potência ativa instantânea de entrada
        figure(10);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,pinstentrada,'LineWidth', 2);
        title('Potência Ativa Isntantânea De Entrada');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Potência [W]');    
        grid on
        hold on
    end
    
    if grafico(11) == 11 || grafico(13) == 13
        %Gráfico de potência ativa média de entrada
        figure(11);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,pmedioentrada,'LineWidth', 2);
        title('Potência Ativa Média De Entrada');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Potência [W]');    
        grid on
        hold on
    end  
    
    if grafico(12) == 12 || grafico(13) == 13
        %Gráfico de potência ativa de saída
        figure(12);
        set(gcf,'color',[0.6 0.7 0.8])
        plot(tempo,psaida,'LineWidth', 2);
        title('Potência Ativa'); %Instantânea');
        xlim([0 tmax]);
        xlabel('Tempo [s]'); 
        ylabel('Potência [W]');  
        grid on
        hold on
%         plot(tempo,pinstentrada,'LineWidth', 2)
%         hold on
%         plot(tempo,pmedioentrada,'LineWidth', 2)
    end 
end    