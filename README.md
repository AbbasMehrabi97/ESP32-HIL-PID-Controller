# 🚀 Hardware-in-the-Loop (HIL) PID Controller: ESP32 & MATLAB

![ESP-IDF](https://img.shields.io/badge/ESP--IDF-v5.0+-red.svg)
![MATLAB](https://img.shields.io/badge/MATLAB-Simulation-blue.svg)
![Control Theory](https://img.shields.io/badge/Control_Systems-PID-success.svg)

## 📌 Project Overview
This project implements a professional **Hardware-in-the-Loop (HIL)** simulation to control a 2nd-order dynamic system. The physical plant is simulated in **MATLAB**, while the mathematical brain (PID Controller) runs purely on an **ESP32 microcontroller** using FreeRTOS. 

Instead of hardcoding values, this system features a **Live Tuning** architecture via UART, allowing real-time parameter adjustments without re-flashing the microcontroller.

## 🧠 Engineering Challenges Solved
Unlike basic tutorial PID codes, this firmware addresses real-world industrial control problems:
* **Integral Windup Protection:** Implemented hard hardware limits (`MAX_INTEGRAL = 300`) to prevent infinite accumulation during saturation (Integral Starvation/Windup).
* **Output Saturation Limits:** Real-world actuators (motors, valves) have limits. The ESP32 enforces strict maximum/minimum control efforts ($U$).
* **Software Auto-Reset:** The controller memory (integral state) automatically wipes clean upon a new MATLAB session to prevent residual state corruption.
* **Second-Order System Damping:** Tuned derivative ($K_d$) actions to tame the natural oscillations of an underdamped 2nd-order plant ($1 / s^2 + 0.5s + 1$).

## ⚙️ System Architecture

1. **MATLAB (The Plant):** Simulates the physics (Eulers method) and sends `[Setpoint]` and `[Current State]` to ESP32.
2. **ESP32 (The Controller):** Parses incoming data, computes the error, runs the Anti-Windup PID algorithm, and sends the `[Control Effort U]` back.
3. **UART Interface:** Acts as the high-speed, closed-loop feedback nervous system.

## 🚀 How to Run

### 1. ESP32 Firmware
Navigate to the `esp32_firmware` folder and flash the code using ESP-IDF:
```bash
idf.py build flash
```
### 2. MATLAB Live Tuning
    1. Open matlab_simulation/hil_live_tuning.m.
    2. Update the port variable to match your ESP32 (e.g., COM3 or
    dev/ttyACM0).
    3. Run the script. Play with $K_p$, $K_i$, $K_d$ parameters 
    directly in the script and re-run to see the live step response!
