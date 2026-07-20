class LocalizationData {
  static const Map<String, Map<String, String>> _localizedValues = {
    'tl': {
      'app_title': 'Santo Rosaryo',
      'today_mystery': 'Misteryo ngayong araw',
      'interactive_title': 'Interaktibong Rosaryo',
      'interactive_subtitle': 'Gabay sa bawat butil ng rosaryo na may kasamang audio at canvas.',
      'guide_title': 'Gabay sa Pagbasa',
      'guide_subtitle': 'Buong teksto ng pagdarasal mula sa simula hanggang wakas.',
      'repeat_x': 'ULITIN NANG X',
      'step': 'Hakbang',
      'of': 'ng',
      'reading': 'Nagbabasa...',
      'meditation': 'PAGNINILAY-NILAY',
      'next_our_father': 'SUSUNOD: AMA NAMIN',
      'restart': 'Simula',
      'back': 'Bago',
      'stop': 'Tigilan',
      'auto': 'Auto',
      'dialog_close': 'Isara',
      'dialog_again': 'Muli',
      'dialog_title': 'Natapos ang Rosaryo!',
      'dialog_body': 'Salamat sa inyong debosyon.\nPanatag nawa ang inyong kalooban.',
    },
    'en': {
      'app_title': 'Holy Rosary',
      'today_mystery': 'Today\'s Mystery',
      'interactive_title': 'Interactive Rosary',
      'interactive_subtitle': 'Guided bead-by-bead rosary with audio and canvas.',
      'guide_title': 'Reading Guide',
      'guide_subtitle': 'Full text of prayers from beginning to end.',
      'repeat_x': 'REPEAT X',
      'step': 'Step',
      'of': 'of',
      'reading': 'Reading...',
      'meditation': 'MEDITATION',
      'next_our_father': 'NEXT: OUR FATHER',
      'restart': 'Restart',
      'back': 'Back',
      'stop': 'Stop',
      'auto': 'Auto',
      'dialog_close': 'Close',
      'dialog_again': 'Again',
      'dialog_title': 'Rosary Completed!',
      'dialog_body': 'Thank you for your devotion.\nMay peace be with you.',
    },
  };

  static String getText(String lang, String key) {
    return _localizedValues[lang]?[key] ?? key;
  }
}
