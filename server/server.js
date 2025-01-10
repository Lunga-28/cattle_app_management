const mongoose = require('mongoose');
const express = require('express');
const cors = require('cors');
const app = express();
const userRouter = require('./routes/userRoutes');
const authRouter = require('./routes/authRoutes');
const financeRouter = require('./routes/financesRoutes');
const cattleRouter = require('./routes/cattleRoutes');
const weatherRouters = require('./routes/weatherRoutes');

require('dotenv').config();
app.use(express.json());
app.use(cors());


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


const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

module.exports = app;
