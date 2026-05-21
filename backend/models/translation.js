const mongoose = require('mongoose');

const translationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false // Optional for anonymous translations
  },
  originalText: {
    type: String,
    required: true
  },
  translatedText: {
    type: String,
    required: true
  },
  sourceLang: String,
  targetLang: String,
  mode: {
    type: String,
    enum: ['text', 'ocr', 'voice', 'ai'],
    default: 'text'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Translation', translationSchema);
