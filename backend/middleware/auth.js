const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'aylantro_super_secret_jwt_key_2026';

module.exports = (req, res, next) => {
    const authHeader = req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Authentication token required' });
    }

    const token = authHeader.replace('Bearer ', '');

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded; // { id, email }
        next();
    } catch (error) {
        res.status(401).json({ error: 'Invalid or expired authentication token' });
    }
};
