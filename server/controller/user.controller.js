const User = require("../models/user.model.js");
const bcryptjs = require("bcryptjs");
const errorHandler = require("../utils/error.js");

// Get user profile
const getUserProfile = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id).select('-password');
        if (!user) {
            return next(errorHandler(404, "User not found"));
        }
        res.status(200).json(user);
    } catch (error) {
        next(error);
    }
};

// Update user profile
const updateProfile = async (req, res, next) => {
    const { username, farm_name, farm_code } = req.body;
    
    try {
        // Check if username already exists
        if (username) {
            const existingUser = await User.findOne({ username, _id: { $ne: req.user.id } });
            if (existingUser) {
                return next(errorHandler(400, "Username already exists"));
            }
        }

        // Check if farm_code already exists
        if (farm_code) {
            const existingFarm = await User.findOne({ farm_code, _id: { $ne: req.user.id } });
            if (existingFarm) {
                return next(errorHandler(400, "Farm code already exists"));
            }
        }

        const updatedUser = await User.findByIdAndUpdate(
            req.user.id,
            {
                $set: {
                    username: username || undefined,
                    farm_name: farm_name || undefined,
                    farm_code: farm_code || undefined,
                }
            },
            { new: true, runValidators: true }
        ).select('-password');

        res.status(200).json(updatedUser);
    } catch (error) {
        next(error);
    }
};

// Change password
const changePassword = async (req, res, next) => {
    const { currentPassword, newPassword } = req.body;

    try {
        const user = await User.findById(req.user.id);
        if (!user) {
            return next(errorHandler(404, "User not found"));
        }

        // Verify current password
        const isMatch = await bcryptjs.compare(currentPassword, user.password);
        if (!isMatch) {
            return next(errorHandler(400, "Current password is incorrect"));
        }

        // Hash new password
        const hashedPassword = bcryptjs.hashSync(newPassword, 10);
        
        // Update password
        user.password = hashedPassword;
        await user.save();

        res.status(200).json({ message: "Password updated successfully" });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getUserProfile,
    updateProfile,
    changePassword,
};