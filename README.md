Got Your Back 🚴‍♂️⚠️
Got Your Back is an AI-powered bike safety system designed to improve cyclist awareness and communication on the road. The project combines computer vision, BLE communication, and embedded systems to create a low-cost smart biking assistant for everyday riders.

Overview
Cyclists often have limited awareness of fast-approaching vehicles behind them and rely on hand signals that may not always be visible or safe. Got Your Back addresses these problems with:
AI-based rear hazard detection
Real-time rider alerts
Smart left/right turn signaling
The system is designed for environments with heavy bike traffic such as college campuses and urban roads.

Features: 

🚗 AI Vehicle Detection
A computer vision model using OpenAI API call running on a smartphone continuously analyzes the surroundings behind the cyclist using the phone camera. The model detects approaching vehicles and classifies situations as:
Safe
Vehicle Detected
Danger / Fast Approaching Vehicle

📡 BLE Communication
The phone sends hazard information wirelessly over Bluetooth Low Energy (BLE) to an ESP32 mounted on the bike.
Example messages:
S → Safe
D → Danger detected
🔊 Real-Time Rider Alerts
When a dangerous situation is detected, the ESP32 activates a buzzer to immediately alert the rider without requiring them to look at a screen or remove focus from the road.

🕹️ Smart Turn Signaling
A joystick mounted on the handlebars allows the rider to signal:
Left turn
Right turn
using LED indicators mounted on the bike.



Hardware Used
ESP32-C6
Smartphone running computer vision model
Active buzzer
Joystick module
LEDs
Battery pack

Technologies
Arduino IDE
BLE GATT Communication
ESP32 Embedded Systems
Computer Vision / AI Detection
Swift + CoreBluetooth
Embedded C++

