const mongoose = require('mongoose');
const express = require('express');
const cors = require('cors');
const app = express();
const userRouter = require('./routes/userRoutes');
const authRouter = require('./routes/authRoutes');
const financeRouter = require('./routes/financesRoutes');
const cattleRouter = require('./routes/cattleRoutes');
const weatherRouters = require('./routes/weatherRoutes');
const healthRouter = require('./routes/healthRoutes');
const feedRouter = require('./routes/feedRoutes');

require('dotenv').config();

// CORS Configuration
const corsOptions = {
  origin: [
    'http://localhost:3000',
    'http://localhost',
    'http://10.0.2.2:3000',    // Android emulator
    'http://localhost:50000',   // Flutter web debug port
    'http://localhost:50001'    // Alternative Flutter web port
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization'
  ],
  credentials: true,
  maxAge: 86400
};


// Middleware
app.use(express.json());
app.use(cors(corsOptions));

// Additional security headers
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  next();
});

// Connect to MongoDB
mongoose.connect(process.env.MONGO, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Set up routes
app.use('/api/user', userRouter);
app.use('/api/auth', authRouter);
app.use('/api/finances', financeRouter);
app.use('/api/cattle', cattleRouter);
app.use('/api/weather', weatherRouters);
app.use('/api/health', healthRouter);
app.use('/api/feed', feedRouter);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

module.exports = app; 