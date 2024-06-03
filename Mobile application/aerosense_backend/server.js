const express = require('express');
const openCollection = require('./database/databaseConnection');
const postAirQuality = require('./helpers/openweather_helper');
// const postTempAndSchedule = require('./helpers/openweatherTemp_helper');
const app = express();
const socketIo = require('socket.io');
const { initWebSocketServerAndChangeStream } = require('./controllers/userController');
const { initSocketServerAndChangeStream } = require('./controllers/userController');
const router = require('./router/routes'); 
const cors = require('cors'); 
const alive = require('./keep_alive');

//parsing incoming json data
app.use(express.json());
app.use(cors());
app.use("/", router);
const collectionName = 'realtime_db';
openCollection(collectionName);
openCollection(collectionName)
  .then(collection => {

    collection.findOne({}).then(result => {
      console.log("Result from the database:", result);
    });
  })
  .catch(error => {
    console.error("Error:", error);
  });

const server = app.listen(8000, () => {
  
    console.log('Server is running on port 8000');
}
);
const io = socketIo(server);
io.on('connection', (socket) => {
    console.log('Client connected');
    socket.on('disconnect', () => {
        console.log('Client disconnected');
    });
});
initWebSocketServerAndChangeStream(io);
initSocketServerAndChangeStream(io);

