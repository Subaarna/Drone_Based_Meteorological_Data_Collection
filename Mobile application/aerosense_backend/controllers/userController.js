const openCollection = require('../database/databaseConnection');
const User = require('../models/userModel').User;
const { UserLogin } = require('../models/userModel');
const bcrypt = require('bcrypt');
const {promisify} = require('util');
const {ObjectId} = require('mongodb');
const { GenerateAccessToken } = require('../helpers/authHelper');
const { GenerateRefreshToken } = require('../helpers/authHelper');
const { generateVerificationToken} = require('../helpers/authHelper');
const IsAuthenticated = require('../helpers/authHelper').IsAuthenticated;
const nodemailer = require('nodemailer');
const { format } = require('date-fns');
require('dotenv').config();


const pass = process.env.GM_PASS;
saltRounds = 10;


function serverTest(req, res) {
  try {
    const jsonResponse = { message: "Server is alive!" };
    res.status(200).json(jsonResponse);
  } catch (error) {
    console.error('Error initializing alive message:', error);
    const errorResponse = { error: 'Error initializing alive message' };
  res.status(500).json(errorResponse);
  }
}

// Function to initialize WebSocket server and listen for changes
async function initWebSocketServerAndChangeStream(io) {
  try {
    // Open the collection and wait for the promise to resolve
    const realtimeDataCollection = await openCollection("RealtimeOpenWeatherData");
    
    // Check if the realtimeDataCollection object has the watch method
    if (typeof realtimeDataCollection.watch === 'function') {
      // Create the change stream
      const changeStream = realtimeDataCollection.watch();
      
      // Listen for changes in the collection
      changeStream.on('change', (change) => {
          console.log('Change detected:', change);

          // Emit the updated data to connected clients
          broadcastUpdatedDataow(io);
      });
    } else {
      console.log("realtimeDataCollection does not have the watch method");
    }
  } catch (error) {
      console.error('Error initializing WebSocket server and change stream:', error);
  }
}

async function broadcastUpdatedDataow(io) {
  try {
      const realtimeDataCollection = await openCollection("RealtimeOpenWeatherData");
      const data = await realtimeDataCollection.find()
      .sort({ _id: -1 }) ///data in descending order
      .limit(1) // showing only one document
      .toArray();
      io.emit('dataUpdate', data);
  } catch (error) {
      console.error('Error broadcasting data update:', error);
  }
}


async function initSocketServerAndChangeStream(io) {
  try {
    // Open the collection and wait for the promise to resolve
    const realtimeDataCollection = await openCollection("RealtimeDroneData");
    
    // Check if the realtimeDataCollection object has the watch method
    if (typeof realtimeDataCollection.watch === 'function') {
      // Create the change stream
      const changeStream = realtimeDataCollection.watch();
      
      // Listen for changes in the collection
      changeStream.on('change', (change) => {
          console.log('Change detected:', change);

          // Emit the updated data to connected clients
          broadcastUpdatedData(io);
      });
    } else {
      console.log("realtimeDataCollection does not have the watch method");
    }
  } catch (error) {
      console.error('Error initializing WebSocket server and change stream:', error);
  }
}


async function broadcastUpdatedData(io) {
  try {
      const realtimeDataCollection = await openCollection("RealtimeDroneData");
      const dronedata = await realtimeDataCollection.find()
      .sort({ _id: -1 }) ///data in descending order
      .limit(1) // showing only one document
      .toArray();
      io.emit('DroneDataUpdate', dronedata);
  } catch (error) {
      console.error('Error broadcasting data update:', error);
  }
}


async function initialData(req, res){
try{
  const realtimeDataCollection = await openCollection("RealtimeOpenWeatherData");
  const data = await realtimeDataCollection.find()
  .sort({ _id: -1 }) 
  .limit(1) 
  .toArray();
  return res.json(data);
}
catch(error){
  console.error('Error fetching initial-data update:', error);
}
}


async function createUser(req, res) {
  try {
    const userCollection = await openCollection("users");
    const user = new User(req.body.email, req.body.password);
      // Check if the email already exists
      const existingUser = await userCollection.findOne({ email: user.email });
      if (existingUser) {
        return res
          .status(409)
          .json({ error: "User with this email already exists" });
      }
    // Generate a verification token
    const verificationToken = generateVerificationToken();

    // Hash the password before storing it in the database
    const hashedPassword = await bcrypt.hash(user.password, saltRounds);
    user.password = hashedPassword;
    user.status = 'pending'; 
    user.verificationToken = verificationToken;
    const result = await userCollection.insertOne(user);
    await sendVerificationEmail(user.email, verificationToken);

    // Check if the insertion was successful
    if (result.acknowledged && result.insertedId) {
      return res.json({ message: "User created successfully. Verification email sent." });
    } else {
      return res.json({ error: "Failed to create user" });
    }
  } catch (error) {
    // checking for duplicated entry
    if (error.code === 11000 && error.keyPattern.email) {
      return res.status(400).json({ error: "User with this email already exists" });
    }
    console.error("Error creating user:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}


async function sendVerificationEmail(email, verificationToken) {
  try {
      const info = await transporter.sendMail({
          from: 'np03cs4s220271@heraldcollege.edu.np',
          to: email,
          subject: "Email Verification",
          html: `<p>Dear User,</p>
              <p>Please verify your email address by clicking the following link:</p>
              <p><a href="https://drone-based-meteorological-data.onrender.com/verifyEmail?token=${verificationToken}">Verify Email</a></p>`,
      });

      console.log("Verification email sent: %s", info.messageId);
      return info;
  } catch (error) {
      console.error("Error sending verification email:", error);
      throw error;
  }
}


async function verifyEmail(req, res) {
  try {
      const { token } = req.query;
      const userCollection = await openCollection("users");

      // Find the user with the verification token
      const user = await userCollection.findOne({ verificationToken: token });

      if (!user) {
          return res.status(404).json({ error: "Invalid verification token" });
      }

      // Update user status to active
      await userCollection.updateOne({ _id: user._id }, { $set: { status: 'active' } });

      return res.json({ message: "Email verified successfully" });
  } catch (error) {
      console.error("Error verifying email:", error);
      return res.status(500).json({ error: "Internal server error" });
  }
}


async function login(req, res) {
  try {
    const userCollection = await openCollection("users");
    const user = new UserLogin(req.body.email, req.body.password);
    

    const existingUser = await userCollection.findOne({ email: user.email });
    
    if (!existingUser) {
      return res.status(401).json({ error: "User with this email does not exist" });
    }

    //checking if uer is verified or not
    if (existingUser.status !== "active") {
      return res.status(401).json({ error: "User account not yet activated. Please verify your email first." });
    }

    
    const isPasswordValid = await bcrypt.compare(user.password, existingUser.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({ error: "Invalid password" });
    }

    // Generate access and refresh tokens
    const accessToken = GenerateAccessToken(existingUser._id.toHexString());
    const refreshToken = GenerateAccessToken(existingUser._id.toHexString());

    return res.json({
      message: "Login successful",
      ID: existingUser._id,
      email: existingUser.email,
      accessToken: accessToken,
      refreshToken: refreshToken,
    });
  } catch (error) {
    console.error("Error during login:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}


async function getDataForLast24Hours(req, res) {
  try {
    const currentTime = new Date();
    const twentyFourHoursAgo = new Date(currentTime - 24 * 60 * 60 * 1000); // Calculate 24 hours ago
    
    const realtimeDataCollection = await openCollection("RealtimeOpenWeatherData");
    
    // Query for data within the last 24 hours
    const data = await realtimeDataCollection.find({
      // Converting to seconds since Unix epoch
      timestamp: { $gte: twentyFourHoursAgo.getTime() / 1000 } 
    }).toArray();

    // Initializing the variables for highest and lowest values
    let highestTemperature = -Infinity; 
    let lowestTemperature = Infinity; 
    let highestPM25 = -Infinity; 
    let lowestPM25 = Infinity; 
    let highestHumidity = -Infinity; 
    let lowestHumidity = Infinity; 
    
    // Iterating over each data entry to find highest and lowest values
    data.forEach(entry => {
      const temperature = entry.temperature;
      const pm25 = entry.pm2_5;
      const humidity = entry.humidity;

      // Updating highest and lowest temperatures
      if (temperature > highestTemperature) {
        highestTemperature = temperature;
      }
      if (temperature < lowestTemperature) {
        lowestTemperature = temperature;
      }

      // Updating highest and lowest PM2.5 values
      if (pm25 > highestPM25) {
        highestPM25 = pm25;
      }
      if (pm25 < lowestPM25) {
        lowestPM25 = pm25;
      }

      // Updating highest and lowest humidity values
      if (humidity > highestHumidity) {
        highestHumidity = humidity;
      }
      if (humidity < lowestHumidity) {
        lowestHumidity = humidity;
      }
    });

    return res.json({
      highestTemperature,
      lowestTemperature,
      highestPM25,
      lowestPM25,
      highestHumidity,
      lowestHumidity,
      data 
    });
  } catch (error) {
    console.error('Error fetching data:', error);
    return res.json({ error: "Internal server error" });
  }
}


async function getDataForLast24HoursDrone(req, res) {
  try {
    const currentTime = new Date();
    const twentyFourHoursAgo = new Date(currentTime - 24 * 60 * 60 * 1000); // Calculate 24 hours ago
    
    const realtimeDataCollection = await openCollection("RealtimeDroneData");
    
    // Query for data within the last 24 hours
    const data = await realtimeDataCollection.find({
      // Converting to seconds since Unix epoch
      _id: { $gte: twentyFourHoursAgo.getTime() / 1000 } 
    }).toArray();

    // Initializing the variables for highest and lowest values
    let highestTemperature = -Infinity; 
    let lowestTemperature = Infinity; 
    let highestPM25 = -Infinity; 
    let lowestPM25 = Infinity; 
    let highestHumidity = -Infinity; 
    let lowestHumidity = Infinity; 
    
    // Iterating over each data entry to find highest and lowest values
    data.forEach(entry => {
      const temperature = entry.temperature;
      const pm25 = entry.pm2_5;
      const humidity = entry.humidity;

      // Updating highest and lowest temperatures
      if (temperature > highestTemperature) {
        highestTemperature = temperature;
      }
      if (temperature < lowestTemperature) {
        lowestTemperature = temperature;
      }

      // Updating highest and lowest PM2.5 values
      if (pm25 > highestPM25) {
        highestPM25 = pm25;
      }
      if (pm25 < lowestPM25) {
        lowestPM25 = pm25;
      }

      // Updating highest and lowest humidity values
      if (humidity > highestHumidity) {
        highestHumidity = humidity;
      }
      if (humidity < lowestHumidity) {
        lowestHumidity = humidity;
      }
    });

    return res.json({
      highestTemperature,
      lowestTemperature,
      highestPM25,
      lowestPM25,
      highestHumidity,
      lowestHumidity,
      // data 
    });
  } catch (error) {
    console.error('Error fetching data:', error);
    return res.json({ error: "Internal server error" });
  }
}


async function getDataForLastWeek(req, res) {
  try {
    const currentTime = new Date();
    const sevenDaysAgo = new Date(currentTime - 6 * 24 * 60 * 60 * 1000); 
    
    const realtimeDataCollection = await openCollection("RealtimeOpenWeatherData");
    
    // Query for data within the last week
    const data = await realtimeDataCollection.find({
      // Converting to seconds since Unix epoch
      timestamp: { $gte: sevenDaysAgo.getTime() / 1000 } 
    }).sort({ timestamp: -1 }).toArray();

    // Initialize an object to store highest and lowest values for each day
    const dailyStats = {};

    // Iterate over each data entry to calculate highest and lowest values for each day
    data.forEach(entry => {
      // Extract the date (ignoring time) from the timestamp and format it
      const date = format(new Date(entry.timestamp * 1000), "iiii, do MMMM"); 
      
      // If the date is not already in the dailyStats object, initialize it
      if (!dailyStats[date]) {
        dailyStats[date] = {
          highestTemperature: -Infinity,
          lowestTemperature: Infinity,
          highestPM25: -Infinity,
          lowestPM25: Infinity,
          highestHumidity: -Infinity,
          lowestHumidity: Infinity,
          weatherMainCounts: {}, 
        };
      }
      // Update highest and lowest values for each parameter
      const { temperature, pm2_5, humidity, weatherMain } = entry;
      const dailyStat = dailyStats[date];
      dailyStat.highestTemperature = Math.max(dailyStat.highestTemperature, temperature);
      dailyStat.lowestTemperature = Math.min(dailyStat.lowestTemperature, temperature);
      dailyStat.highestPM25 = Math.max(dailyStat.highestPM25, pm2_5);
      dailyStat.lowestPM25 = Math.min(dailyStat.lowestPM25, pm2_5);
      dailyStat.highestHumidity = Math.max(dailyStat.highestHumidity, humidity);
      dailyStat.lowestHumidity = Math.min(dailyStat.lowestHumidity, humidity);

      // Update counts for weatherMain values
      dailyStat.weatherMainCounts[weatherMain] = (dailyStat.weatherMainCounts[weatherMain] || 0) + 1;
    });

    // Find the most repeated weatherMain value for each day
    Object.values(dailyStats).forEach(dailyStat => {
      const weatherMainCounts = dailyStat.weatherMainCounts;
      const mostRepeatedCondition = Object.keys(weatherMainCounts).reduce((a, b) => weatherMainCounts[a] > weatherMainCounts[b] ? a : b);
      dailyStat.mostRepeatedWeatherMain = mostRepeatedCondition;
      //removing the temporary weatherMainCounts property
      delete dailyStat.weatherMainCounts;
    });

    return res.json(dailyStats);
  } catch (error) {
    console.error('Error fetching data:', error);
    return res.json({ error: "Internal server error" });
  }
}


async function getDataForLastWeekDrone(req, res) {
  try {
    const currentTime = new Date();
    const sevenDaysAgo = new Date(currentTime - 7 * 24 * 60 * 60 * 1000); // Calculate 7 days ago
    
    const realtimeDataCollection = await openCollection("RealtimeDroneData");
    
    // Query for data within the last week
    const data = await realtimeDataCollection.find({
      // Converting to seconds since Unix epoch
      _id: { $gte: sevenDaysAgo.getTime() / 1000 } 
    }).toArray();

    // Initialize an object to store statistics for each day
    const dailyStats = {};

    // Iterate over each data entry to calculate statistics for each day
    data.forEach(entry => {
      // Extract the date (ignoring time) from the timestamp and format it
      const date = format(new Date(entry._id * 1000), "iiii, do MMMM"); 
      
      // If the date is not already in the dailyStats object, initialize it
      if (!dailyStats[date]) {
        dailyStats[date] = {
          highestTemperature: -Infinity,
          lowestTemperature: Infinity,
          highestPM25: -Infinity,
          lowestPM25: Infinity,
          highestPM10: -Infinity,
          lowestPM10: Infinity,
          highestUVIndex: -Infinity,
          lowestUVIndex: Infinity,
          weatherMainCounts: {}, 
        };
      }

      // Update highest and lowest values for each parameter
      const { temperature, pm2_5, pm10, uvIndex, weatherMain } = entry;
      const dailyStat = dailyStats[date];
      dailyStat.highestTemperature = Math.max(dailyStat.highestTemperature, temperature);
      dailyStat.lowestTemperature = Math.min(dailyStat.lowestTemperature, temperature);
      dailyStat.highestPM25 = Math.max(dailyStat.highestPM25, pm2_5);
      dailyStat.lowestPM25 = Math.min(dailyStat.lowestPM25, pm2_5);
      dailyStat.highestPM10 = Math.max(dailyStat.highestPM10, pm10);
      dailyStat.lowestPM10 = Math.min(dailyStat.lowestPM10, pm10);
      dailyStat.highestUVIndex = Math.max(dailyStat.highestUVIndex, uvIndex);
      dailyStat.lowestUVIndex = Math.min(dailyStat.lowestUVIndex, uvIndex);

      // Update counts for weatherMain values
      dailyStat.weatherMainCounts[weatherMain] = (dailyStat.weatherMainCounts[weatherMain] || 0) + 1;
    });

    // Find the most repeated weatherMain value for each day
    Object.values(dailyStats).forEach(dailyStat => {
      const weatherMainCounts = dailyStat.weatherMainCounts;
      const mostRepeatedCondition = Object.keys(weatherMainCounts).reduce((a, b) => weatherMainCounts[a] > weatherMainCounts[b] ? a : b);
      dailyStat.mostRepeatedWeatherMain = mostRepeatedCondition;
      // Removing the temporary weatherMainCounts property
      delete dailyStat.weatherMainCounts;
    });

    return res.json(dailyStats);
  } catch (error) {
    console.error('Error fetching data:', error);
    return res.json({ error: "Internal server error" });
  }
}


async function forgotPassword(req, res) {
  try {
    const { email } = req.body;
    const userCollection = await openCollection("users");
    const user = await userCollection.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Generate a new refresh token for the user
    const refreshToken = GenerateRefreshToken(user._id);

    // Update user document with the new refresh token
    await userCollection.updateOne({ _id: user._id }, {
      $set: {
        refreshToken
      }
    });

    // Send email with reset instructions containing the refresh token and user's email
    await sendResetEmail(user.email, refreshToken);

    return res.json({ 
      message: "Password reset instructions sent to your email", 
      refreshToken
    });
  } catch (error) {
    console.error("Error in forgot password:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
// Create a transporter object
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 465,
  secure:true, 
  auth: {
      user: 'np03cs4s220271@heraldcollege.edu.np',
      pass: pass
  }
});

async function sendResetEmail(email, resetToken) {
  try {
    // Send mail with defined transport object
    const info = await transporter.sendMail({
      from: 'np03cs4s220271@heraldcollege.edu.np', 
      to: email, // Recipient's email
      subject: "Password Reset", // Subject line
      html: `<p>Dear User,</p>
      <p>We hope this message finds you well.</p>
      <p>Kindly proceed by clicking on the following link to reset your password:</p>
      <p><a href="https://www.subarnadevkota.com.np/password_reset.html?token=${resetToken}">Reset Password</a></p>`, // HTML body with reset link
    });      

    console.log("Message sent: %s", info.messageId);
    return info;
  } catch (error) {
    console.error("Error sending reset email:", error);
    throw error;
  }
}
async function resetPassword(req, res) {
  try {
      const { newPassword, confirmPassword, token } = req.body;
      
      // Check if newPassword matches confirmPassword
      if (newPassword !== confirmPassword) {
          return res.status(400).json({ error: "Passwords do not match" });
      }

      // Find the user by the reset token
      const userCollection = await openCollection("users");
      const user = await userCollection.findOne({ refreshToken: token });

      if (!user) {
          return res.status(404).json({ error: "Invalid or expired token" });
      }

      // Hash the new password
      const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

      // Update the user's password in the database
      await userCollection.updateOne({ _id: user._id }, {
          $set: {
              password: hashedPassword
          }
      });

      return res.status(200).json({ message: "Password reset successfully" });
  } catch (error) {
      console.error("Error resetting password:", error);
      return res.status(500).json({ error: "Internal server error" });
  }
}




module.exports = {
  initWebSocketServerAndChangeStream,
  initSocketServerAndChangeStream,
  createUser, 
  initialData,
  login,
  getDataForLast24Hours,
  getDataForLast24HoursDrone,
  forgotPassword,
  resetPassword,
  sendVerificationEmail,
  verifyEmail,
  getDataForLastWeek,
  serverTest,
  getDataForLastWeekDrone
};
