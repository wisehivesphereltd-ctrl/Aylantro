const { dbQuery } = require('../db/sqlite');

exports.getHistory = async (req, res) => {
    const userId = req.user.id;
    try {
        const history = await dbQuery.all(`
            SELECT id, source_lang as sourceLanguage, target_lang as targetLanguage, source_text as sourceText, translated_text as translatedText, created_at as timestamp
            FROM history
            WHERE user_id = ?
            ORDER BY created_at DESC
            LIMIT 100
        `, [userId]);

        res.json({ success: true, history });
    } catch (error) {
        console.error('❌ Get History Error:', error.message);
        res.status(500).json({ error: 'Failed to fetch translation history' });
    }
};

exports.addHistory = async (req, res) => {
    const userId = req.user.id;
    const { sourceLang, targetLang, sourceText, translatedText } = req.body;

    if (!sourceLang || !targetLang || !sourceText || !translatedText) {
        return res.status(400).json({ error: 'Missing translation history parameters' });
    }

    try {
        const result = await dbQuery.run(`
            INSERT INTO history (user_id, source_lang, target_lang, source_text, translated_text)
            VALUES (?, ?, ?, ?, ?)
        `, [userId, sourceLang, targetLang, sourceText, translatedText]);

        res.status(201).json({ success: true, historyId: result.lastID });
    } catch (error) {
        console.error('❌ Add History Error:', error.message);
        res.status(500).json({ error: 'Failed to save translation to history' });
    }
};

exports.clearHistory = async (req, res) => {
    const userId = req.user.id;
    try {
        await dbQuery.run("DELETE FROM history WHERE user_id = ?", [userId]);
        res.json({ success: true, message: 'Translation history cleared successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to clear translation history' });
    }
};
