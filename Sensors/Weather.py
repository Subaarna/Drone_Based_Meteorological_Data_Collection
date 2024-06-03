import time
import smbus
import smbus2
import bme280
import serial
import cv2
import tempfile
from pymongo import MongoClient
from pymongo.server_api import ServerApi
from roboflow import Roboflow

# Define PCF8591 constants
PCF8591_I2C_ADDR = 0x48  # I2C address of the PCF8591 module
port = 1
#bme280 sensor address
address = 0x76  

# Initialize I2C bus
bus = smbus.SMBus(0)  # Use I2C bus 1 on Raspberry Pi
bus_bme = smbus2.SMBus(port)

# Load calibration parameters for BME sensor
calibration_params = bme280.load_calibration_params(bus_bme, address)

# MongoDB connection URI
uri = "mongodb+srv://'Your_user and password'@cluster0.yu7zxbt.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi('1'))

# Access the database
db = client["realtime_db"]

# Access the collection
collection = db["RealtimeDroneData"]


rf = Roboflow(api_key="jLfMGtP7qTrkJq46AWyk")
project = rf.workspace().project("weather-classification-rdmuk")
model = project.version(1).model

# Initialize the webcam
cap = cv2.VideoCapture(0)  

# Set frame capture size to 600x600
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 600)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 600)

def read_analog_data():
    # Reading analog data from PCF8591 module 
    data = bus.read_byte_data(PCF8591_I2C_ADDR, 0)  
    return data

def convert_to_voltage(sensor_value):
    # Convert analog data to voltage 
    voltage = sensor_value * (5000.0 / 1023.0)
    return voltage

def convert_to_uv_index(voltage):
    if voltage < 50:
        return 0
    elif voltage <= 227:
        return 2
    elif voltage <= 318:
        return 2
    elif voltage <= 408:
        return 3
    elif voltage <= 503:
        return 4
    elif voltage <= 606:
        return 5
    elif voltage <= 696:
        return 6
    elif voltage <= 795:
        return 7
    elif voltage <= 881:
        return 8
    elif voltage <= 976:
        return 9
    elif voltage <= 1079:
        return 10
    else:
        return 11

def read_sensor(port='/dev/ttyUSB0'):
    ser = serial.Serial(port, baudrate=9600, timeout=2.0)
    while True:
        # Send command to read data
        ser.write(b'\xAA\xB4\x04\x00\x00\x00\x00\x00\xFF\xFF\x00\xAB')

        # Read response
        raw_data = ser.read(10)

        # Parse data
        if raw_data[0] == 0xAA and raw_data[1] == 0xC0:
            pm25 = (raw_data[3] * 256 + raw_data[2]) / 10.0
            pm10 = (raw_data[5] * 256 + raw_data[4]) / 10.0
            return pm25, pm10

        # Wait before next reading
        time.sleep(2)

try:
    print("Timestamp\tTemperature\tWeatherMain\tPM2.5\tPM10\tUV Index")
    while True:
        # Get current timestamp
        timestamp = int(time.time())

        # Read temperature from BME sensor
        bme280_data = bme280.sample(bus_bme, address, calibration_params)
        temperature = bme280_data.temperature

        # Make a prediction on weather using the camera
        ret, frame = cap.read()
        temp_filename = tempfile.NamedTemporaryFile(suffix=".jpg", delete=False).name
        cv2.imwrite(temp_filename, frame)
        prediction = model.predict(temp_filename).json()
        weather_main = prediction.get('predictions', [])[0].get('predicted_classes', ['Unknown'])

        # Read PM2.5 and PM10 from sensor
        pm25, pm10 = read_sensor()

        # Read UV index from analog sensor
        uv_voltage = read_analog_data()
        uv_index = convert_to_uv_index(uv_voltage)

        # Insert data into MongoDB
        data_to_insert = {
            "_id": timestamp,
            "temperature": temperature,
            "weatherMain": weather_main,
            "pm2_5": pm25,
            "pm10": pm10,
            "uvIndex": uv_index
        }
        collection.insert_one(data_to_insert)

        # Print data with proper alignment
        print(f"{timestamp}\t{temperature:.2f}\t{weather_main[0] if weather_main else 'Unknown'}\t\t{pm25:.2f}\t{pm10:.2f}\t{uv_index}")

        # Delay for a short period before taking the next reading
        time.sleep(5)

except KeyboardInterrupt:
    pass

# Release resources
cap.release()
client.close()
