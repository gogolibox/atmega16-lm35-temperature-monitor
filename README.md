# ATmega16 Temperature Monitoring System

## Project Overview

This project is an embedded temperature monitoring system based on the ATmega16 microcontroller. It reads analog temperature data from an LM35 sensor using the ADC and displays the measured temperature on a 1602 LCD in 4-bit mode.

The system is implemented using both C and AVR Assembly, demonstrating low-level hardware control alongside higher-level embedded programming techniques. The project also includes a full Proteus simulation and a compiled HEX file for direct execution.

---

## Features

- Real-time temperature measurement using LM35 sensor
- ADC configuration on ATmega16
- LCD interfacing in 4-bit mode (1602 display)
- Dual implementation in C and AVR Assembly
- Proteus simulation project included
- Precompiled HEX file for direct microcontroller programming

---

## Hardware Components

- ATmega16 microcontroller  
- LM35 temperature sensor  
- 1602 LCD display  
- Basic passive components (resistors, wiring)

---

## Software Tools

- AVR-GCC (C development)  
- AVR Assembly  
- Proteus Design Suite (simulation)  
- Microcontroller programming via HEX file

---

## Project Structure  
```
LM35.c               # C implementation  
LM35.asm             # AVR Assembly implementation  
LM35.hex             # Compiled HEX file for ATmega16  
LM35.pdsprj          # Proteus simulation project  
README.md
```
---

## How to Run (Proteus)

1. Open the Proteus project file
2. Load the provided `.hex` file into the ATmega16 microcontroller
3. Run the simulation to observe real-time temperature output on the LCD

---

## Video Explanation

🎥 https://drive.google.com/file/d/13m6dn7vO2twImeLK4HyAWsrJ_nEOF_Xe/view?usp=sharing

---

## Notes

- The project demonstrates both high-level (C) and low-level (Assembly) implementation approaches.
- The HEX file is ready for direct use in simulation or hardware deployment.
- All code and simulation files are included for full reproducibility.
