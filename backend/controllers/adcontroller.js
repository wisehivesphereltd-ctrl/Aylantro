const { dbQuery } = require('../db/sqlite');

let cachedAd = {
  title: 'Upgrade to Aylantro Premium',
  subtitle: 'Unlock unlimited AI Context translation and real-time document OCR',
  imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop&q=80',
  actionUrl: 'https://aylantro.com/premium',
  isActive: 1
};

exports.getLatestAd = async (req, res) => {
  try {
    const ad = await dbQuery.get(`
      SELECT title, subtitle, image_url as imageUrl, action_url as actionUrl, is_active as isActive
      FROM ads
      WHERE is_active = 1
      ORDER BY id DESC
      LIMIT 1
    `);
    if (ad) {
      cachedAd = ad;
    }
    res.json(cachedAd);
  } catch (error) {
    console.warn('⚠️ SQLite ad fetch failed, serving in-memory cached ad');
    res.json(cachedAd);
  }
};

exports.updateAd = async (req, res) => {
  const { title, subtitle, actionUrl, imageUrl } = req.body;
  
  cachedAd = { title, subtitle, actionUrl, imageUrl, isActive: 1 };

  try {
    await dbQuery.run(`
      INSERT INTO ads (title, subtitle, action_url, image_url, is_active)
      VALUES (?, ?, ?, ?, 1)
    `, [title, subtitle, actionUrl, imageUrl]);

    res.json({ success: true, ad: cachedAd });
  } catch (error) {
    console.error('Ad Update Error:', error);
    res.status(500).json({ error: 'Failed to update ad in SQL database', ad: cachedAd });
  }
};
