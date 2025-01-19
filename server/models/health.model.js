const mongoose = require('mongoose');

const healthSchema = new mongoose.Schema({
    cattleId: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Cattle', 
        required: true 
    },
    date: { 
        type: Date, 
        default: Date.now 
    },
    type: { 
        type: String, 
        enum: ['Vaccination', 'Treatment', 'Check-up', 'Disease', 'Other'],
        required: true 
    },
    description: { 
        type: String, 
        required: true 
    },
    medicines: [{
        name: { type: String },
        dosage: { type: String },
        duration: { type: String }
    }],
    veterinarian: { 
        type: String 
    },
    nextCheckupDate: { 
        type: Date 
    },
    cost: { 
        type: Number 
    },
    createdBy: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    }
}, { timestamps: true });

module.exports = mongoose.model("Health", healthSchema)