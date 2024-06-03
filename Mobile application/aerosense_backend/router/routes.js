const express = require("express");
const router = express.Router();
const userController = require('../controllers/userController');
const {initWebSocketServerAndChangeStream} = require('../controllers/userController');
const http = require('http');
const socketIo = require('socket.io');


router.get('/ws', (req, res) => {
    res.send('WebSocket server is running.');
});

router.get('/posts', (req, res) => {
    res.json(posts,);
});
// router.get('/socket', userController)
router.post('/signup', userController.createUser);
router.post('/login', userController.login);
router.get('/initialData', userController.initialData);
router.get('/historicalowData', userController.getDataForLast24Hours);
router.get('/historicaldrData', userController.getDataForLast24HoursDrone);
router.post('/forgotPassword', userController.forgotPassword);
router.post('/resetPassword', userController.resetPassword);
router.get('/verifyEmail',userController.verifyEmail );
router.get('/archiveow', userController.getDataForLastWeek);
router.get('/archivedr', userController.getDataForLastWeekDrone);
router.get('/test', userController.serverTest);
module.exports = router;