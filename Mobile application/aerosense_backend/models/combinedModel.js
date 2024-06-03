class CombinedModel {
    constructor(temp, timestamp, humidity, cityName, weatherMain, pm2_5, pm10, longitude, latitude) {
        this.temperature = temp;
        this.timestamp = timestamp;
        this.humidity = humidity;
        this.cityName = cityName;
        this.weatherMain = weatherMain; 
        this.pm2_5 = pm2_5;
        this.pm10 = pm10;
        this.longitude = longitude;
        this.latitude = latitude;
    }
}

module.exports = CombinedModel;
