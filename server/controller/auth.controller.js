const User = require("../models/user.model.js");
const bcryptjs = require("bcryptjs");
const errorHandler = require("../utils/error.js");
const jwt = require("jsonwebtoken");

// Utility function for generating JWT tokens
const generateToken = (payload) => {
    return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || "1h" });
};

// Signup function
const signup = async (req, res, next) => {
    const { username, email, password, farm_code, farm_name } = req.body;

    // Check required fields
    if (!username || !email || !password || 
        username.trim() === "" || 
        email.trim() === "" || 
        password.trim() === "") {
        return next(errorHandler(400, "Username, email, and password are required"));
    }

    try {
        // Hash the password
        const hashedPassword = bcryptjs.hashSync(password, 10);

        // Create new user
        const newUser = new User({
            username,
            email,
            password: hashedPassword,
            farm_code: farm_code || null,
            farm_name: farm_name || null,
        });

        // Save user to the database
        await newUser.save();

        // Generate JWT token
        const token = generateToken({ id: newUser._id, farm_code: newUser.farm_code });

        // Exclude sensitive fields like password before responding
        const { password: pass, ...rest } = newUser._doc;

        res.status(201)
           .cookie("access_token", token, { httpOnly: true })
           .json({ message: "Signup successful", user: rest });
    } catch (error) {
        // Handle unique constraint violations
        if (error.code === 11000) {
            const duplicateField = Object.keys(error.keyPattern)[0];
            const fieldName = duplicateField === "farm_code" ? "Farm code" : duplicateField;
            return next(errorHandler(400, `${fieldName} already exists`));
        }
        next(error);
    }
};

// Signin function
const signin = async (req, res, next) => {
    const { email, password } = req.body;

    if (!email || !password || email.trim() === "" || password.trim() === "") {
        return next(errorHandler(400, "All fields are required"));
    }

    try {
        // Find the user by email
        const validuser = await User.findOne({ email });
        if (!validuser) {
            return next(errorHandler(404, "User not found"));
        }

        // Verify the password
        const isMatch = bcryptjs.compareSync(password, validuser.password);
        if (!isMatch) {
            return next(errorHandler(400, "Invalid credentials"));
        }

        // Generate JWT token
        const token = generateToken({ id: validuser._id, farm_code: validuser.farm_code });

        // Exclude sensitive fields like password before responding
        const { password: pass, ...rest } = validuser._doc;

        // Send token in both cookie and response body
        res.status(200)
           .cookie("access_token", token, { 
               httpOnly: true,
               secure: process.env.NODE_ENV === 'production',
               sameSite: 'strict'
           })
           .json({
               ...rest,
               access_token: token // Include token in response body for mobile clients
           });
    } catch (error) {
        next(error);
    }
};

// Google sign-in or sign-up function
const google = async (req, res, next) => {
    const { name, email, googlePhotoUrl } = req.body;

    try {
        const user = await User.findOne({ email });

        if (user) {
            // Generate JWT token
            const token = generateToken({ id: user._id, farm_code: user.farm_code });

            // Exclude sensitive fields like password before responding
            const { password, ...rest } = user._doc;

            res.status(200)
               .cookie("access_token", token, { httpOnly: true })
               .json(rest);
        } else {
            // Create a new user
            const generatedPassword = Math.random().toString(36).slice(-8);
            const hashedPassword = bcryptjs.hashSync(generatedPassword, 10);

            const newUser = new User({
                username: name.toLowerCase().split(" ").join("") + Math.random().toString(9).slice(-4),
                email,
                password: hashedPassword,
                profilePicture: googlePhotoUrl,
                farm_code: null,
                farm_name: null,
            });

            await newUser.save();

            // Generate JWT token
            const token = generateToken({ id: newUser._id, farm_code: newUser.farm_code });

            // Exclude sensitive fields like password before responding
            const { password, ...rest } = newUser._doc;

            res.status(200)
               .cookie("access_token", token, { httpOnly: true })
               .json(rest);
        }
    } catch (error) {
        if (error.code === 11000) {
            return next(errorHandler(400, "User with this email already exists"));
        }
        next(error);
    }
};

module.exports = {
    signup,
    signin,
    google,
};
