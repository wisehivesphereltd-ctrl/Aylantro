const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const admin = require('firebase-admin');
const path = require('path');

dotenv.config({ path: path.resolve(__dirname, '.env') });

console.log('📝 ENV Check: Loaded successfully');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Import Controllers
let translationController, aiController, adController, authController, historyController;
try {
  translationController = require('./controllers/translationcontroller');
  aiController = require('./controllers/aicontroller');
  adController = require('./controllers/adcontroller');
  authController = require('./controllers/authcontroller');
  historyController = require('./controllers/historycontroller');
  console.log('✅ Controllers loaded successfully');
} catch (error) {
  console.error('❌ Controller Load Error:', error.message);
}

const authMiddleware = require('./middleware/auth');

// Initialize Firebase Admin (Independent Safety)
try {
  const serviceAccount = require('./service_account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin Initialized');
} catch (error) {
  console.error('⚠️ Firebase Admin Skip:', error.message);
}

// Create Router for /api
const apiRouter = express.Router();

// Health Check on Router
apiRouter.get('/', (req, res) => {
  res.json({ message: 'Aylantro AI API is ready', status: 'ONLINE', database: 'SQLite SQL' });
});

// Debug on Router
apiRouter.get('/debug', (req, res) => {
  res.json({
    controllersLoaded: !!(translationController && aiController && authController && adController),
    sqliteStatus: 'Connected (Local SQL Layer Active)'
  });
});

// Authentication & Profile Routes
apiRouter.post('/auth/register', authController.register);
apiRouter.post('/auth/login', authController.login);
apiRouter.get('/auth/profile', authMiddleware, authController.getProfile);
apiRouter.post('/auth/fcm-token', authMiddleware, authController.updateFcmToken);

// Cloud History Sync Routes
apiRouter.get('/history', authMiddleware, historyController.getHistory);
apiRouter.post('/history', authMiddleware, historyController.addHistory);
apiRouter.delete('/history', authMiddleware, historyController.clearHistory);

// Translation Routes on Router
apiRouter.post('/translate', (req, res, next) => {
  if (!translationController) return res.status(500).json({ error: 'Translation Controller not loaded' });
  translationController.translateText(req, res, next);
});

apiRouter.post('/ocr', (req, res, next) => {
  if (!translationController) return res.status(500).json({ error: 'OCR Controller not loaded' });
  translationController.ocrAndTranslate(req, res, next);
});

apiRouter.post('/ai/translate', (req, res, next) => {
  if (!aiController) return res.status(500).json({ error: 'AI Controller not loaded' });
  aiController.aiTranslate(req, res, next);
});

// Push Notification Route
apiRouter.post('/admin/send-notification', async (req, res) => {
    const { title, body, topic = 'allUsers' } = req.body;
    try {
        const message = { notification: { title, body }, topic: topic };
        await admin.messaging().send(message);
        res.json({ success: true, message: 'Notification sent successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to send notification', details: error.message });
    }
});

// Ad Routes
apiRouter.get('/ad', (req, res) => {
    if (!adController) return res.status(500).json({ error: 'Ad Controller not loaded' });
    adController.getLatestAd(req, res);
});

apiRouter.post('/admin/update-ad', (req, res) => {
    if (!adController) return res.status(500).json({ error: 'Ad Controller not loaded' });
    adController.updateAd(req, res);
});

// Mount the Router at /api
app.use('/api', apiRouter);

// Root Health Check
app.get('/', (req, res) => {
  res.json({ message: 'Aylantro AI Backend is running', status: 'OK', server: 'Node.js/SQLite' });
});

// Final Catch-all 404
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    requestedPath: req.path,
    originalUrl: req.originalUrl
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
