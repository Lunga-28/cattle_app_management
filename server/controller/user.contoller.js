const User = require('../models/user.model');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const secret = process.env.JWT_SECRET || 'secret123';

// User signup
exports.signup = async (req, res) => {
  try {
    const { username, password, farmName } = req.body;

    if (await User.findOne({ username }))
      return res.status(400).json({ error: 'Username already exists' });

    const user = new User({ username, password, farmName });
    await user.save();
    res.status(201).json({ message: 'User created' });
  } catch (error) {
    res.status(500).json({ error: 'Signup failed' });
  }
};

// User login
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });

    if (!user || !(await bcrypt.compare(password, user.password)))
      return res.status(401).json({ error: 'Invalid credentials' });

    const token = jwt.sign({ id: user._id }, secret, { expiresIn: '1d' });
    res.json({ token });
  } catch (error) {
    res.status(500).json({ error: 'Login failed' });
  }
};
