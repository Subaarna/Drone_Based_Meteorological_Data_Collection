# Drone-based Meteorological Data Collection System

## Overview
This here is my Final Year Project, a drone based Meteorological Data collection System that senses certain weather parameters with the help of sensor where the drone acts as a carrier for the weather sensors, integration of RaspberryPi with a 4G USB modem lets the drone to have limitless telemetry and onboard computing power, Integration of a machine learning model on RaspberryPI that can classify weather conditions based off of image captured, and a user-friendly mobile application with Real-time and Historical Weather Data.
## Features
- **Sensor Integration**: 
  - **BME280**: Temperature, humidity, and pressure sensor.
  - **SDS011**: Air quality sensor for particulate matter (PM2.5 and PM10).
  - **UVM30A**: UV index sensor.
- **Image Capture and Transmission**: Raspberry Pi captures images with the help of USB webcam and sends it to the server, reducing load on Pi.
- **4G Modem Integration**: Data transmission and limitless telemetry via 4G connection.
- **Weather Classification**: Uses a machine learning model hosted on Hugging Face to classify weather conditions (sunny, rainy, cloudy, snowy, foggy) based on captured images.
- **Mobile Application**: Provides user registration with email verification, user login, password recovery, and real-time and historical weather data interface.
- **Cross-validation**: Compares drone-captured data with OpenWeather's real-time and historical data for accuracy.
![image](https://github.com/Subaarna/Meteorological_Data_Collection_Using_Drone-FYP-/assets/66509028/7224a003-26bf-40cb-9b86-55416a8e349d)

## Components
1. **Drone and Hardware**:
    - **Raspberry Pi**: Central controller for sensor data collection and image capture.
    - **Sensors**: BME280, SDS011, UVM30A.
    - **4G Modem**: For data transmission and telemetry.
2. **Software**:
    - **Python Scripts**: For initiating data collection from sensors.
    - **Machine Learning Model**: Deployed on Hugging Face for weather classification.
    - **Mobile Application**: Developed for user interaction and data visualization.

## Installation and Setup

### Hardware Setup
1. **Assemble the Drone**:
    - Attach the sensors (BME280, SDS011, UVM30A) to the drone.
    - Connect the Raspberry Pi to the sensors and 4G modem.

2. **Configure Raspberry Pi**:
    - Install necessary libraries and dependencies.
    - Set up the 4G modem for internet connectivity.

### Software Setup
1. **Clone the Repository**:
    ```sh
    git clone https://github.com/yourusername/drone-meteorological-system.git
    cd drone-meteorological-system
    ```

2. **Run Data Collection Script**:
    ```sh
    python weather.py
    ```

3. **Deploy Machine Learning Model**:
    - Ensure the model is accessible on Hugging Face.
    - Update the script to interface with the Hugging Face model API.

4. **Mobile Application**:
    - Ensure that Flutter for frontend and Node.js for backend is installed properly on your device.
    - Ensure backend services are running for user authentication and data handling(For this project Backend services were hosted on render.com at [https://meteorological-data-collection-using-wh35.onrender.com].

## Usage

### Data Collection
- The Raspberry Pi will automatically collect data from the connected sensors.
- Images captured by the Pi will be sent to the server for weather classification. Here's the link to the hosted model [https://subarna00-weathermodel.hf.space/docs]

### Weather Classification
- The ML model will classify the weather based on the images and provide real-time weather conditions.

### Mobile Application
- Users can register, log in, and access real-time and historical weather data.
- The app also provides cross-validation with OpenWeather data.
