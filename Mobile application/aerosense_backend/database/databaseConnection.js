const { MongoClient } = require('mongodb');
require('dotenv').config();
const pass = process.env.Mongo_PASS;

const uri = `mongodb+srv://subarna:${pass}@cluster0.yu7zxbt.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`;



async function databaseInstance() {
    try {
        const client = await MongoClient.connect(uri);
        await client.db().command({ ping: 1 });

        console.log("Connected to MongoDB");

        return client;
    } catch (error) {
        console.error("Error connecting to MongoDB", error);
        throw error;
    }
}

const clientPromise = databaseInstance();

function openCollection(collectionName) {
    return clientPromise.then(client => client.db("realtime_db").collection(collectionName));
}


module.exports = openCollection;