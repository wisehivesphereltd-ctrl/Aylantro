const path = require('path');
const fs = require('fs');

let db = null;
let dbQuery = null;

try {
    // Attempt C++ SQLite Native Binding
    const sqlite3 = require('sqlite3').verbose();
    const dbPath = path.resolve(__dirname, '..', 'database.sqlite');
    db = new sqlite3.Database(dbPath, (err) => {
        if (err) console.error('SQLite connection error:', err.message);
    });

    dbQuery = {
        run: (sql, params = []) => new Promise((resolve, reject) => {
            db.run(sql, params, function (err) {
                if (err) reject(err);
                else resolve(this);
            });
        }),
        get: (sql, params = []) => new Promise((resolve, reject) => {
            db.get(sql, params, (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        }),
        all: (sql, params = []) => new Promise((resolve, reject) => {
            db.all(sql, params, (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        })
    };

    // Ensure SQL tables exist
    db.serialize(() => {
        db.run(`CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL, name TEXT NOT NULL, fcm_token TEXT, is_premium INTEGER DEFAULT 0, usage_count INTEGER DEFAULT 0, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`);
        db.run(`CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, source_lang TEXT NOT NULL, target_lang TEXT NOT NULL, source_text TEXT NOT NULL, translated_text TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`);
        db.run(`CREATE TABLE IF NOT EXISTS ads (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, subtitle TEXT, image_url TEXT, action_url TEXT, is_active INTEGER DEFAULT 1, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP)`);
    });

} catch (nativeErr) {
    console.warn('ℹ️ Native SQLite / GLIBC mismatch detected on cPanel. Activating Pure JS SQL Engine...');

    // Pure JS SQL Engine Fallback (Zero Native Dependencies)
    const dbDir = path.resolve(__dirname, '..', 'database');
    if (!fs.existsSync(dbDir)) fs.mkdirSync(dbDir, { recursive: true });

    const getTable = (tableName) => {
        const file = path.join(dbDir, `${tableName}.json`);
        if (!fs.existsSync(file)) fs.writeFileSync(file, JSON.stringify([]));
        try {
            return JSON.parse(fs.readFileSync(file, 'utf8'));
        } catch (_) {
            return [];
        }
    };

    const saveTable = (tableName, data) => {
        const file = path.join(dbDir, `${tableName}.json`);
        fs.writeFileSync(file, JSON.stringify(data, null, 2), 'utf8');
    };

    dbQuery = {
        run: async (sql, params = []) => {
            const cleanSql = sql.trim().toUpperCase();
            if (cleanSql.startsWith('INSERT INTO USERS')) {
                const users = getTable('users');
                const id = (users[users.length - 1]?.id || 0) + 1;
                const newUser = {
                    id,
                    name: params[0],
                    email: params[1],
                    password_hash: params[2],
                    fcm_token: null,
                    is_premium: 0,
                    usage_count: 0,
                    created_at: new Date().toISOString()
                };
                users.push(newUser);
                saveTable('users', users);
                return { lastID: id };
            }
            if (cleanSql.startsWith('INSERT INTO HISTORY')) {
                const history = getTable('history');
                const id = (history[history.length - 1]?.id || 0) + 1;
                const newHist = {
                    id,
                    user_id: params[0],
                    sourceLanguage: params[1],
                    targetLanguage: params[2],
                    sourceText: params[3],
                    translatedText: params[4],
                    timestamp: new Date().toISOString()
                };
                history.push(newHist);
                saveTable('history', history);
                return { lastID: id };
            }
            if (cleanSql.startsWith('INSERT INTO ADS')) {
                const ads = getTable('ads');
                const id = (ads[ads.length - 1]?.id || 0) + 1;
                const newAd = {
                    id,
                    title: params[0],
                    subtitle: params[1],
                    actionUrl: params[2],
                    imageUrl: params[3],
                    isActive: 1,
                    updated_at: new Date().toISOString()
                };
                ads.push(newAd);
                saveTable('ads', ads);
                return { lastID: id };
            }
            if (cleanSql.startsWith('UPDATE USERS SET FCM_TOKEN')) {
                const users = getTable('users');
                const index = users.findIndex(u => u.id == params[1]);
                if (index !== -1) {
                    users[index].fcm_token = params[0];
                    saveTable('users', users);
                }
                return { changes: 1 };
            }
            if (cleanSql.startsWith('DELETE FROM HISTORY')) {
                let history = getTable('history');
                history = history.filter(h => h.user_id != params[0]);
                saveTable('history', history);
                return { changes: 1 };
            }
            return { changes: 0 };
        },
        get: async (sql, params = []) => {
            const cleanSql = sql.trim().toUpperCase();
            if (cleanSql.includes('FROM USERS WHERE EMAIL = ?')) {
                const users = getTable('users');
                return users.find(u => u.email.toLowerCase() === params[0]?.toLowerCase());
            }
            if (cleanSql.includes('FROM USERS WHERE ID = ?')) {
                const users = getTable('users');
                return users.find(u => u.id == params[0]);
            }
            if (cleanSql.includes('FROM ADS')) {
                const ads = getTable('ads');
                if (ads.length === 0) {
                    return {
                        title: 'Upgrade to Aylantro Premium',
                        subtitle: 'Unlock unlimited AI Context translation and real-time document OCR',
                        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop&q=80',
                        actionUrl: 'https://aylantro.com/premium',
                        isActive: 1
                    };
                }
                return ads[ads.length - 1];
            }
            return null;
        },
        all: async (sql, params = []) => {
            const cleanSql = sql.trim().toUpperCase();
            if (cleanSql.includes('FROM HISTORY WHERE USER_ID = ?')) {
                const history = getTable('history');
                return history.filter(h => h.user_id == params[0]).reverse().slice(0, 100);
            }
            return [];
        }
    };
}

module.exports = { db, dbQuery };
