const User = require("../models/user.model.js");
const bcryptjs = require("bcryptjs");
const errorHandler = require("../utils/error.js");
const jwt = require("jsonwebtoken");

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
        res.status(201).json({ message: "Signup successful" });
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


const signin = async (req, res, next) => {
    const { email, password } = req.body;
    if (!email || !password ||
        email.trim() === "" ||
        password.trim() === "") {
        return next(errorHandler(400, "All fields are required"));
    }
   
    
    try {
        const validuser = await User.findOne({ email });
        if (!validuser) {
            return next(errorHandler(404, "User not found"));
        }
       
        const isMatch = bcryptjs.compareSync(password, validuser.password);
        if (!isMatch) {
            return next(errorHandler(400, "Invalid credentials"));
        }
       
        const token = jwt.sign(
            { 
                id: validuser._id,
                farm_code: validuser.farm_code
            },
            process.env.JWT_SECRET
        );
       
        const { password: pass, ...rest } = validuser._doc;
       
        res.status(200)
           .cookie('access_token', token, { httpOnly: true })
           .json(rest);
    } catch (error) {
        next(error);
    }
};


const google = async (req, res, next) => {
    const { name, email, googlePhotoUrl } = req.body;
    try {
        const user = await User.findOne({ email });
        if (user) {
            const token = jwt.sign(
                { 
                    id: user._id,
                    farm_code: user.farm_code
                },
                process.env.JWT_SECRET
            );
            const { password, ...rest } = user._doc;
            res.status(200)
               .cookie('access_token', token, { httpOnly: true })
               .json(rest);
        } else {
            const generatedPassword =
                Math.random().toString(36).slice(-8) +
                Math.random().toString(36).slice(-8);
            const hashedPassword = bcryptjs.hashSync(generatedPassword, 10);
           
            const newUser = new User({
                username: name.toLowerCase().split(' ').join('') +
                         Math.random().toString(9).slice(-4),
                email,
                password: hashedPassword,
                profilePicture: googlePhotoUrl,
                farm_code: null,
                farm_name: null
            });
           
            await newUser.save();
            const token = jwt.sign(
                { 
                    id: newUser._id,
                    farm_code: newUser.farm_code
                },
                process.env.JWT_SECRET
            );
           
            const { password, ...rest } = newUser._doc;
            res.status(200)
               .cookie('access_token', token, { httpOnly: true })
               .json(rest);
        }
    } catch(error) {
        if (error.code === 11000) {
            return next(errorHandler(400, "User with this email already exists"));
        }
        next(error);
    }
};

module.exports = {
    signup,
    signin,
    google
};