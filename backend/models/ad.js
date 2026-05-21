const mongoose = require('mongoose');

const adSchema = new mongoose.Schema({
  title: { type: String, required: true, default: 'WISEHIVE SPHERE ADS' },
  subtitle: { type: String, required: true, default: 'Test Placement - Verified by Aylantro AI' },
  imageUrl: { type: String },
  link: { type: String },
  isActive: { type: Boolean, default: true },
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Ad', adSchema);
