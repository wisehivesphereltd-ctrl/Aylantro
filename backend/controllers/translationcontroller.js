const { TranslationServiceClient } = require('@google-cloud/translate');
const vision = require('@google-cloud/vision');
const path = require('path');

// Initialize Google Cloud Clients
const keyPath = path.join(__dirname, '..', 'service_account.json');

const visionClient = new vision.ImageAnnotatorClient({
  keyFilename: keyPath,
});

const translateClient = new TranslationServiceClient({
  keyFilename: keyPath,
});

/**
 * Text Translation Logic
 */
exports.translateText = async (req, res) => {
  const { text, targetLang, sourceLang } = req.body;

  if (!text || !targetLang) {
    return res.status(400).json({ error: 'Text and targetLang are required' });
  }

  try {
    const projectId = require(keyPath).project_id;
    const location = 'global';

    const request = {
      parent: `projects/${projectId}/locations/${location}`,
      contents: [text],
      mimeType: 'text/plain',
      sourceLanguageCode: sourceLang || 'en',
      targetLanguageCode: targetLang,
    };

    const [response] = await translateClient.translateText(request);
    const translatedText = response.translations[0].translatedText;

    res.json({
      originalText: text,
      translatedText: translatedText,
      sourceLang: response.translations[0].detectedLanguageCode || sourceLang,
      targetLang
    });
  } catch (error) {
    console.error('❌ TRANSLATION CRITICAL ERROR:', error);
    res.status(500).json({ 
      error: 'Translation failed', 
      details: error.message,
      code: error.code
    });
  }
};

/**
 * OCR & Translation Logic (Vision)
 */
exports.ocrAndTranslate = async (req, res) => {
  const { image, targetLang } = req.body;

  if (!image) {
    return res.status(400).json({ error: 'Image data is required' });
  }

  try {
    const buffer = Buffer.from(image, 'base64');
    
    // Official Google Vision request format
    const [result] = await visionClient.documentTextDetection({
      image: { content: buffer }
    });
    
    const fullText = result.fullTextAnnotation ? result.fullTextAnnotation.text : '';

    if (!fullText) {
      console.log('ℹ️ No text detected in image');
      return res.json({ message: 'No text detected', detectedText: '', translatedText: '' });
    }

    // Now translate the detected text
    const keyData = require(keyPath);
    const projectId = keyData.project_id;
    
    const request = {
      parent: `projects/${projectId}/locations/global`,
      contents: [fullText],
      mimeType: 'text/plain',
      targetLanguageCode: targetLang || 'en',
    };

    const [translateResponse] = await translateClient.translateText(request);
    const translatedText = translateResponse.translations[0].translatedText;

    res.json({
      detectedText: fullText,
      translatedText: translatedText,
      targetLang
    });
  } catch (error) {
    console.error('❌ OCR CRITICAL ERROR:', error);
    res.status(500).json({ 
      error: 'OCR processing failed', 
      details: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};
