const { OpenAI } = require('openai');

let openai;
const getOpenAIClient = () => {
  if (!openai) {
    if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
      throw new Error('OpenAI API Key is missing or invalid in .env file');
    }
    openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }
  return openai;
};

exports.aiTranslate = async (req, res) => {
  const { text, targetLang, context } = req.body;

  if (!text || !targetLang) {
    return res.status(400).json({ error: 'Text and targetLang are required' });
  }

  try {
    const openai = getOpenAIClient();
    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: `You are a professional translator for Aylantro AI. 
          Translate the text to ${targetLang}. 
          Maintain the tone and context. 
          Provide only the translated text.`
        },
        {
          role: "user",
          content: context ? `Context: ${context}\nText: ${text}` : text
        }
      ],
      temperature: 0.3,
    });

    const translatedText = response.choices[0].message.content.trim();

    res.json({
      originalText: text,
      translatedText,
      targetLang,
      engine: 'gpt-4o'
    });
  } catch (error) {
    console.error('OpenAI Error:', error);
    res.status(500).json({ error: 'AI Translation failed', details: error.message });
  }
};
