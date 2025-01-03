const mongoose = require('mongoose');
const express = require('express');
const cors = require('cors');
const app = express();

require('dotenv').config();
app.use(express.json());
app.use(cors());

mongoose.connect(process.env.MONGO, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

module.exports = app;
