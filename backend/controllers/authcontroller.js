const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { dbQuery } = require('../db/sqlite');

const JWT_SECRET = process.env.JWT_SECRET || 'aylantro_super_secret_jwt_key_2026';

exports.register = async (req, res) => {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
        return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    try {
        // Check if user already exists
        const existingUser = await dbQuery.get("SELECT id FROM users WHERE email = ?", [email.toLowerCase()]);
        if (existingUser) {
            return res.status(400).json({ error: 'Email already registered' });
        }

        // Hash password
        const passwordHash = await bcrypt.hash(password, 12);

        // Insert new user into SQLite SQL database
        const result = await dbQuery.run(`
            INSERT INTO users (name, email, password_hash)
            VALUES (?, ?, ?)
        `, [name, email.toLowerCase(), passwordHash]);

        const userId = result.lastID;

        // Generate JWT Token
        const token = jwt.sign({ id: userId, email: email.toLowerCase() }, JWT_SECRET, { expiresIn: '30d' });

        res.status(201).json({
            success: true,
            token,
            user: { id: userId, name, email: email.toLowerCase(), isPremium: 0, usageCount: 0 }
        });
    } catch (error) {
        console.error('❌ Register Error:', error.message);
        res.status(500).json({ error: 'Failed to create user account' });
    }
};

exports.login = async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
    }

    try {
        const user = await dbQuery.get("SELECT * FROM users WHERE email = ?", [email.toLowerCase()]);
        if (!user) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '30d' });

        res.json({
            success: true,
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                isPremium: user.is_premium,
                usageCount: user.usage_count
            }
        });
    } catch (error) {
        console.error('❌ Login Error:', error.message);
        res.status(500).json({ error: 'Failed to log in' });
    }
};

exports.getProfile = async (req, res) => {
    const userId = req.user.id;
    try {
        const user = await dbQuery.get("SELECT id, name, email, is_premium, usage_count, created_at FROM users WHERE id = ?", [userId]);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ success: true, user });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch user profile' });
    }
};

exports.updateFcmToken = async (req, res) => {
    const userId = req.user.id;
    const { fcmToken } = req.body;
    if (!fcmToken) {
        return res.status(400).json({ error: 'FCM token is required' });
    }

    try {
        await dbQuery.run("UPDATE users SET fcm_token = ? WHERE id = ?", [fcmToken, userId]);
        res.json({ success: true, message: 'FCM token updated successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to save FCM token' });
    }
};
