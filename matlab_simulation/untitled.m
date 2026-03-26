% --- ESP32 HIL PID CONTROL TEST (PRO VERSION) ---

port = "/dev/ttyACM0"; 
baudrate = 115200;

try
    s = serialport(port, baudrate);
    configureTerminator(s, "LF");
    
    % AUTO SOFTWARE RESET (Otomatik Yazilimsal Reset)
    flush(s); 
    write(s, "RESET\n", "string"); % Clear ESP32 integral memory (ESP32 hafizasini sifirla)
    pause(0.2); 
    flush(s); 
    
    disp('Live Tuning Connection Established! Brain Wiped (Baglanti Kuruldu, Hafiza Temiz).');
catch
    error('Port could not be opened! (Port acilamadi!)');
end

% SYSTEM PARAMETERS (Sistem Parametreleri)
setpoint = 5.0;     
y = 0.0;            
dt = 0.05; 
v = 0.0;

% PID GAINS (PID Katsayilari - Canli Ayar Merkezi)
Kp = 2.0;   % Proportional Gain (Oransal - Gaz)
Ki = 0.2;   % Integral Gain (Integral - Inatci Hafiza)
Kd = 1.0;   % Derivative Gain (Turev - Sonumleyici Fren)

% PLOT SETTINGS (Grafik Ayarlari)
figure('Name', 'ESP32 Live Tuning PID');
h = animatedline('Color', 'r', 'LineWidth', 2);
line([0 500], [setpoint setpoint], 'Color', 'b', 'LineStyle', '--', 'LineWidth', 1.5);
axis([0 500 -2 8]); 
xlabel('Time / Steps (Zaman / Adim)'); ylabel('System Output (Cikis - y)'); 
title('Industrial PID Test (Endustriyel PID Testi)');
grid on;

% CLOSED-LOOP CONTROL (Kapali Cevrim Kontrol)
for i = 1:500 
    % Send state and gains to ESP32 (ESP32'ye durumlari ve katsayilari yolla)
    mesaj = sprintf('%.2f,%.2f,%.2f,%.2f,%.2f\n', setpoint, y, Kp, Ki, Kd);
    write(s, mesaj, "string");
    
    % Read Control Effort U (Kontrol Sinyali U'yu oku)
    cevap = readline(s);
    cevap_str = char(cevap);
    
    if startsWith(cevap_str, 'U:')
        U = str2double(cevap_str(3:end));
        
        % Data filter (Hata filtresi)
        if isnan(U)
            continue; 
        end
        
        % 2ND-ORDER PLANT DYNAMICS (2. Dereceden Fiziksel Sistem Simulasyonu)
        % Equation: y'' + 0.5y' + y = U
        y = y + dt * v;                   % Position update (Konum guncellemesi)
        v = v + dt * (U - 0.5*v - y);     % Velocity update (Hiz guncellemesi)
        
        addpoints(h, i, y);
        drawnow limitrate; % Smooth rendering (Akici cizim)
    end
end
clear s;
disp('Test Finished! (Test Bitti!)');
