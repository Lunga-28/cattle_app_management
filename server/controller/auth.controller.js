const User = require("../model/user.model.js");
const Farm = require("../model/farm.model.js");
const Staff = require('../model/staff.model.js');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const errorHandling = require("../utils/error.js");
const crypto = require('crypto');

// Standard sign-up function with farm creation for owners/managers
const signup = async (req, res, next) => {
    const { username, email, password, role, farm_name } = req.body;

    // Log incoming request data
    console.log('Request to standard sign-up:', req.body);

    if (!username || !email || !password) {
        return next(errorHandling(400, 'All fields are required'));
    }

    try {
        // Create the user first
        const hashPassword = bcrypt.hashSync(password, 10);
        const newUser = new User({
            username,
            email,
            password: hashPassword,
            
        });

        const savedUser = await newUser.save();

        // Create the farm if the role is 'owner' or 'manager'


            const newFarm = new Farm({
                farm_name,
                farm_code: crypto.randomBytes(4).toString('hex'), // Generate a unique farm code
                owner: savedUser._id, // Use the saved user's ObjectId
            });

            await newFarm.save();
        

        res.status(201).json({ message: 'User and farm created successfully' });
    } catch (error) {
        console.error('Error during standard signup:', error);
        next(error);
    }
};

// Sign-in function
const signin = async (req, res, next) => {
    const { email, password } = req.body;

    // Log incoming request data
    console.log('Request to sign in:', req.body);

    if (!email || !password || email === '' || password === '') {
        return next(errorHandling(400, 'All fields are required'));
    }

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return next(errorHandling(404, 'User not found'));
        }

        const isMatch = bcrypt.compareSync(password, user.password);

        if (!isMatch) {
            return next(errorHandling(401, 'Invalid credentials'));
        }

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
        const { password: pass, ...rest } = user._doc;
        res.status(200).cookie('access_token', token, {
            httpOnly: true,
        }).json(rest);
    } catch (error) {
        console.error('Error during sign-in:', error);
        next(error);
    }
};

module.exports = { signup, signin };
