const { TranslationServiceClient } = require('@google-cloud/translate');
const path = require('path');
const pdfParseModule = require('pdf-parse');
const pdfParse = typeof pdfParseModule === 'function' ? pdfParseModule : (pdfParseModule.PDFParse || pdfParseModule.default || pdfParseModule);
const mammoth = require('mammoth');
const fs = require('fs');

const keyPath = path.join(__dirname, '..', 'service_account.json');
const translateClient = new TranslationServiceClient({
  keyFilename: keyPath,
});

exports.translateDocument = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No document file provided.' });
  }

  const { targetLang } = req.body;
  const filePath = req.file.path;

  if (!targetLang) {
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    return res.status(400).json({ error: 'targetLang is required.' });
  }

  const ext = path.extname(req.file.originalname).toLowerCase();
  const fileBuffer = fs.readFileSync(filePath);
  
  let mimeType = '';
  if (ext === '.pdf') mimeType = 'application/pdf';
  else if (ext === '.docx') mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  else if (ext === '.txt') mimeType = 'text/plain';
  else {
    fs.unlinkSync(filePath);
    return res.status(400).json({ error: 'Unsupported file format. Use PDF, DOCX, or TXT.' });
  }

  try {
    // 1. Extract Original Text for Preview
    let originalText = '';
    if (ext === '.pdf') {
      const pdfData = await pdfParse(fileBuffer);
      originalText = pdfData.text;
    } else if (ext === '.docx') {
      const result = await mammoth.extractRawText({ buffer: fileBuffer });
      originalText = result.value;
    } else if (ext === '.txt') {
      originalText = fileBuffer.toString('utf8');
    }

    if (!originalText || originalText.trim().length === 0) {
      fs.unlinkSync(filePath);
      return res.json({ error: 'No text was detected in the document.' });
    }

    // Google limits translation size, we truncate preview if needed
    const MAX_PREVIEW = 10000;
    let previewOriginal = originalText;
    if (previewOriginal.length > MAX_PREVIEW) previewOriginal = previewOriginal.substring(0, MAX_PREVIEW) + '...';

    const projectId = require(keyPath).project_id;
    let translatedText = '';
    let documentBytesBase64 = '';

    if (ext === '.txt') {
      // translateDocument doesn't support .txt natively, so we use translateText
      const request = {
        parent: `projects/${projectId}/locations/global`,
        contents: [originalText.substring(0, 20000)], // Hard limit for text api
        mimeType: 'text/plain',
        targetLanguageCode: targetLang,
      };
      const [response] = await translateClient.translateText(request);
      translatedText = response.translations[0].translatedText;
      documentBytesBase64 = Buffer.from(translatedText, 'utf8').toString('base64');
    } else {
      // Use Native Document Translation
      const request = {
        parent: `projects/${projectId}/locations/global`,
        documentInputConfig: {
          content: fileBuffer,
          mimeType: mimeType,
        },
        targetLanguageCode: targetLang,
      };

      const [response] = await translateClient.translateDocument(request);
      const translatedBuffer = response.documentTranslation.byteStreamOutputs[0];
      documentBytesBase64 = Buffer.from(translatedBuffer).toString('base64');

      // Extract Translated Text for Preview
      if (ext === '.pdf') {
        const tPdf = await pdfParse(translatedBuffer);
        translatedText = tPdf.text;
      } else if (ext === '.docx') {
        const tDoc = await mammoth.extractRawText({ buffer: translatedBuffer });
        translatedText = tDoc.value;
      }
    }

    let previewTranslated = translatedText;
    if (previewTranslated.length > MAX_PREVIEW) previewTranslated = previewTranslated.substring(0, MAX_PREVIEW) + '...';

    // Cleanup
    fs.unlinkSync(filePath);

    res.json({
      originalText: previewOriginal,
      translatedText: previewTranslated,
      documentBytesBase64,
      mimeType,
      fileName: `Translated_${req.file.originalname}`
    });

  } catch (error) {
    console.error('❌ DOC TRANSLATION ERROR:', error);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    res.status(500).json({ error: 'Document processing failed', details: error.message });
  }
};
