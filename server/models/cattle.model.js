const mongoose = require('mongoose');

const cattleSchema = new mongoose.Schema({
  name: { type: String, required: true },
  breed: { type: String, required: true },
  age: { type: Number, required: false },
  gender: { type: String, enum: ['Male', 'Female'], required: true },
  imageUrl: { type: String }, 
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  healthRecords: [
    {
      date: { type: Date, default: Date.now },
      notes: { type: String },
    },
  ],
  tag_number: { type: String, required: true},
}, { timestamps: true });

module.exports = mongoose.model('Cattle', cattleSchema);
