const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    password: {
        type: String,
        required: true,
    },
    farm_code: {
        type: String,
        required: false,
        unique: true,
    },
    farm_name: {  
        type: String,
        // Make this field optional
        required: false,
    },
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

module.exports = User;
