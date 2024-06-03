console.log("File executed");

const axios = require('axios');
const openCollection = require('../database/databaseConnection');
const CombinedModel = require('../models/combinedModel');
require('dotenv').config(); 
const weatherApiKey = process.env.Weather_API;

async function postTempAndAirQuality(lon, lat) {
    const weatherApiUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${weatherApiKey}`;
const airQualityApiUrl = `https://api.openweathermap.org/data/2.5/air_pollution?lat=${lat}&lon=${lon}&appid=${weatherApiKey}`;


    try {
        const collection = await openCollection("RealtimeOpenWeatherData");

        // Fetch weather data
        const weatherResponse = await axios.get(weatherApiUrl);
        console.log('Weather API Response:', weatherResponse.data);
        const { temp, humidity } = weatherResponse.data.main;
        console.log('Temperature:', temp);
        console.log('Humidity:', humidity);

        // Fetch air quality data
        const airQualityResponse = await axios.get(airQualityApiUrl);
        console.log('Air Quality API Response:', airQualityResponse.data);
        
        
        const { pm2_5, pm10 } = airQualityResponse.data.list[0].components; 
        console.log('pm2_5:', pm2_5);
        console.log('pm10:', pm10);
        const weatherMain = weatherResponse.data.weather[0].main;

        // Extracting city name
        const cityName = weatherResponse.data.name;

        // Create CombinedModel instance
        const combinedModel = new CombinedModel(
            temp,
            weatherResponse.data.dt,
            humidity,
           
            cityName,
            weatherMain, 
            pm2_5,
            pm10,
            lon,
            lat
        );
        console.log('CombinedModel:', combinedModel);

       
        const result = await collection.insertOne(combinedModel);
        console.log('Insertion result:', result);

        console.log('Data posted successfully.');

    } catch (error) {
        console.error('Error fetching or posting data:', error);
        console.error('API Request Error:', error.response.data);
    }
}


async function postTempAndAirQualityAndSchedule(lon, lat) {
    await postTempAndAirQuality(lon, lat); // Post data immediately when the program starts
    setInterval(async () => {
        await postTempAndAirQuality(lon, lat); // Post data every 10 minutes
    }, 600000);
}

const lon = 85.33072639985875; 
const lat = 27.712203337741006; 

postTempAndAirQualityAndSchedule(lon, lat); // Call the function to post data and schedule subsequent posts
