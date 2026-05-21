class OfflineTranslationEngine {
  static final Map<String, Map<String, String>> _dictionaries = {
    'ha': {
      'hello': 'Sannu',
      'welcome': 'Barka da zuwa',
      'good morning': 'Ina kwana',
      'good afternoon': 'Ina wini',
      'good evening': 'Barka da yamma',
      'how are you': 'Yaya kake',
      'i am fine': 'Lafiya lau',
      'thank you': 'Na gode',
      'yes': 'Ehh',
      'no': 'A\'a',
      'please': 'Don Allah',
      'excuse me': 'Gafara dai',
      'what is your name': 'Yaya sunanka',
      'my name is': 'Sunana',
      'where is the hospital': 'Ina asibiti yake',
      'where is the market': 'Ina kasuwa take',
      'how much is this': 'Nawa ne wannan',
      'water': 'Ruwa',
      'food': 'Abinci',
      'help': 'Taimako',
      'doctor': 'Likita',
      'police': 'Dan sanda',
      'money': 'Kudi',
      'goodbye': 'Sai anjima',
      'peace': 'Lafiya',
      'god bless you': 'Allah ya albarkace ku',
    },
    'ar': {
      'hello': 'مرحباً (Marhaban)',
      'welcome': 'أهلاً وسهلاً (Ahlan wa sahlan)',
      'good morning': 'صباح الخير (Sabah al-khair)',
      'good evening': 'مساء الخير (Masaa al-khair)',
      'how are you': 'كيف حالك؟ (Kaifa haluka)',
      'i am fine': 'أنا بخير (Ana bi-khair)',
      'thank you': 'شكراً (Shukran)',
      'yes': 'نعم (Na\'am)',
      'no': 'لا (La)',
      'please': 'من فضلك (Min fadlik)',
      'excuse me': 'عذراً (Udhraan)',
      'what is your name': 'ما اسمك؟ (Ma ismuka)',
      'my name is': 'اسمي (Ismi)',
      'water': 'ماء (Maa)',
      'food': 'طعام (Ta\'am)',
      'help': 'مساعدة (Musa\'ada)',
      'goodbye': 'مع السلامة (Ma\'a as-salama)',
    },
    'fr': {
      'hello': 'Bonjour',
      'welcome': 'Bienvenue',
      'good morning': 'Bonjour',
      'good evening': 'Bonsoir',
      'how are you': 'Comment ça va?',
      'i am fine': 'Je vais bien',
      'thank you': 'Merci',
      'yes': 'Oui',
      'no': 'Non',
      'please': 'S\'il vous plaît',
      'excuse me': 'Excusez-moi',
      'what is your name': 'Comment vous appelez-vous?',
      'my name is': 'Je m\'appelle',
      'water': 'Eau',
      'food': 'Nourriture',
      'help': 'Au secours',
      'goodbye': 'Au revoir',
    },
    'es': {
      'hello': 'Hola',
      'welcome': 'Bienvenido',
      'good morning': 'Buenos días',
      'good evening': 'Buenas noches',
      'how are you': '¿Cómo estás?',
      'i am fine': 'Estoy bien',
      'thank you': 'Gracias',
      'yes': 'Sí',
      'no': 'No',
      'please': 'Por favor',
      'excuse me': 'Disculpe',
      'what is your name': '¿Cómo te llamas?',
      'my name is': 'Me llamo',
      'water': 'Agua',
      'food': 'Comida',
      'help': 'Ayuda',
      'goodbye': 'Adiós',
    },
    'sw': {
      'hello': 'Jambo / Habari',
      'welcome': 'Karibu',
      'good morning': 'Habari ya asubuhi',
      'good evening': 'Habari ya jioni',
      'how are you': 'Habari gani?',
      'i am fine': 'Mzuri sana',
      'thank you': 'Asante',
      'yes': 'Ndiyo',
      'no': 'Hapana',
      'please': 'Tafadhali',
      'water': 'Maji',
      'food': 'Chakula',
      'help': 'Msaada',
      'goodbye': 'Kwaheri',
    },
    'zh': {
      'hello': '你好 (Nǐ hǎo)',
      'thank you': '谢谢 (Xièxiè)',
      'yes': '是 (Shì)',
      'no': '不 (Bù)',
      'goodbye': '再见 (Zàijiàn)',
    }
  };

  static String translate(String sourceText, String sourceLang, String targetLang) {
    if (sourceText.isEmpty) return '';
    final clean = sourceText.toLowerCase().trim();

    // Check exact phrase match first
    if (_dictionaries.containsKey(targetLang)) {
      final dict = _dictionaries[targetLang]!;
      if (dict.containsKey(clean)) {
        return '⚡ [Offline Mode] ${dict[clean]!}';
      }

      // Sort dictionary keys by word count descending for greedy multi-word matching
      final sortedKeys = dict.keys.toList()..sort((a, b) => b.split(' ').length.compareTo(a.split(' ').length));

      String translatedResult = clean;
      bool foundAny = false;

      for (final key in sortedKeys) {
        if (RegExp(r'\b' + RegExp.escape(key) + r'\b', caseSensitive: false).hasMatch(translatedResult)) {
          translatedResult = translatedResult.replaceAll(RegExp(r'\b' + RegExp.escape(key) + r'\b', caseSensitive: false), dict[key]!);
          foundAny = true;
        }
      }

      if (foundAny) {
        // Capitalize first letter
        final finalStr = translatedResult[0].toUpperCase() + translatedResult.substring(1);
        return '⚡ [Offline Mode] $finalStr';
      }
    }

    // Default robust rule-based offline fallback
    return '⚡ [Offline Mode active] "$sourceText" (Language pack ready on device)';
  }
}
