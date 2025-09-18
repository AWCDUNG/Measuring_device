# measuring_device

A new Flutter project.

# IoT-based Air Quality Prediction and Pollution Alert System  

This project is an IoT-based solution for monitoring and predicting air quality.  
It collects sensor data (temperature, humidity, PM2.5, CO, CO2, etc.) and stores it in a MySQL database through a PHP API over HTTP.  
Users can visualize real-time AQI values and receive pollution alerts via web or mobile applications.  

## Features
- Real-time sensor data collection (ESP32 + sensors)  
- Data transfer to server using HTTP requests  
- Backend with **PHP + MySQL** for data storage and management  
- Web dashboard for visualization and alerts  
- AQI calculation and pollution level classification  

## Technologies
- **Hardware**: ESP32, sensors (MQ series, DHT11, etc.)  
- **Backend**: PHP + MySQL (HTTP communication)  
- **Frontend**: Flutter / App 
- **Protocols**: HTTP (POST/GET), JSON  
