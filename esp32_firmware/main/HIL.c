#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

// State variables (Durum degiskenleri)
float previous_error = 0;
float integral = 0;

// Physical limits of the system (Sistemin fiziksel sinirlari)
#define MAX_OUTPUT 10.0
#define MIN_OUTPUT -10.0

// Anti-Windup limit (Integral sismesi onleme siniri)
// Note: Increased to 300 to prevent Integral Starvation (Integral acligini onlemek icin 300'e cikarildi)
#define MAX_INTEGRAL 300.0 

void app_main(void)
{
    printf("\n--- HIL Live Tuning V2 (Anti-Windup & Soft Reset) ---\n");
    char line[128];

    while (1) {
        // Read incoming data stream (Gelen veri akisini oku)
        if (fgets(line, sizeof(line), stdin) != NULL) {
            
            // --- 1. SOFTWARE RESET (Yazilimsal Reset / Beyne Format) ---
            // Wipes the integral memory if "RESET" command is received
            if (strncmp(line, "RESET", 5) == 0) {
                integral = 0;
                previous_error = 0;
                printf("U:0.00\n"); // Send dummy output to keep MATLAB happy
                continue; 
            }

            float setpoint, current_value, Kp, Ki, Kd;

            // Parse 5 float values (5 adet virgullu sayiyi ayikla)
            if (sscanf(line, "%f,%f,%f,%f,%f", &setpoint, &current_value, &Kp, &Ki, &Kd) == 5) {
                
                float error = setpoint - current_value;
                
                // --- 2. ANTI-WINDUP (Hafizayi Dizginleme) ---
                integral += error; 
                // Hardware-level protection against integral windup (Donanimsal sisme korumasi)
                if (integral > MAX_INTEGRAL) integral = MAX_INTEGRAL;
                else if (integral < -MAX_INTEGRAL) integral = -MAX_INTEGRAL;

                float derivative = error - previous_error;
                
                // Compute Control Effort U (Kontrol Sinyali U Hesaplama)
                float output = (Kp * error) + (Ki * integral) + (Kd * derivative);
                
                // --- 3. SATURATION (Motor Cikis Gucunu Sinirlandirma) ---
                if (output > MAX_OUTPUT) output = MAX_OUTPUT;
                else if (output < MIN_OUTPUT) output = MIN_OUTPUT;

                previous_error = error;

                // Send back the safe control effort (Sinirlandirilmis guvenli sonucu yolla)
                printf("U:%.2f\n", output);
            } 
        }
        // Small delay for watchdog timer (Islemcinin nefes almasi icin kisa bekleme)
        vTaskDelay(10 / portTICK_PERIOD_MS);
    }
}