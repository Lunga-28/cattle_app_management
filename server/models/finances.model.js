const mongoose = require('mongoose');

const financesSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Reference to the User
  date: { type: Date, default: Date.now },
  type: { type: String, enum: ['Income', 'Expense'], required: true },
  amount: { type: Number, required: true },
  description: { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Finance', financesSchema);
