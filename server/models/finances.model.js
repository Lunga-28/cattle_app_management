const mongoose = require('mongoose');
const User = require('./user.model.js');

const farmSchema = new mongoose.Schema({
    farm_name: { 
        type: String,
        required: true
    },
    farm_code: { 
        type: String,
        required: true,
        unique: true
    },
    
    owner: { 
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
}, { timestamps: true });

const Farm = mongoose.model('Farm', farmSchema);
module.exports = Farm;
