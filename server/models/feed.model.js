const mongoose = require('mongoose');

const feedSchema = new mongoose.Schema({
    name: { 
        type: String, 
        required: true 
    },
    type: { 
        type: String, 
        enum: ['Fodder', 'Concentrate', 'Mineral', 'Supplement'],
        required: true 
    },
    quantity: { 
        type: Number, 
        required: true 
    },
    unit: { 
        type: String, 
        enum: ['kg', 'g', 'lbs', 'tons'],
        required: true 
    },
    cost: { 
        type: Number, 
        required: true 
    },
    purchaseDate: { 
        type: Date, 
        default: Date.now 
    },
    expiryDate: { 
        type: Date 
    },
    supplier: { 
        type: String 
    },
    stockAlert: { 
        type: Number,  // Minimum quantity threshold for alerts
        required: true 
    },
    nutritionalInfo: {
        protein: Number,
        fiber: Number,
        energy: Number,
        minerals: Number
    },
    notes: { 
        type: String 
    },
    createdBy: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    }
}, { timestamps: true });

module.exports = mongoose.model('Feed', feedSchema);