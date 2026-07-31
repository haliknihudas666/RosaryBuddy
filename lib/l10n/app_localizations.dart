import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tl'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Holy Rosary'**
  String get app_title;

  /// No description provided for @today_mystery.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Mystery'**
  String get today_mystery;

  /// No description provided for @interactive_title.
  ///
  /// In en, this message translates to:
  /// **'Interactive Rosary'**
  String get interactive_title;

  /// No description provided for @interactive_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Guided bead-by-bead rosary with audio and canvas.'**
  String get interactive_subtitle;

  /// No description provided for @guide_title.
  ///
  /// In en, this message translates to:
  /// **'Reading Guide'**
  String get guide_title;

  /// No description provided for @guide_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Full text of prayers from beginning to end.'**
  String get guide_subtitle;

  /// No description provided for @repeat_x.
  ///
  /// In en, this message translates to:
  /// **'REPEAT X'**
  String get repeat_x;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @word_of.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get word_of;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading...'**
  String get reading;

  /// No description provided for @meditation.
  ///
  /// In en, this message translates to:
  /// **'MEDITATION'**
  String get meditation;

  /// No description provided for @next_our_father.
  ///
  /// In en, this message translates to:
  /// **'NEXT: OUR FATHER'**
  String get next_our_father;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @dialog_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialog_close;

  /// No description provided for @dialog_again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get dialog_again;

  /// No description provided for @dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Rosary Completed!'**
  String get dialog_title;

  /// No description provided for @dialog_body.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your devotion.\nMay peace be with you.'**
  String get dialog_body;

  /// No description provided for @intention_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Prayer Intentions'**
  String get intention_dialog_title;

  /// No description provided for @intention_dialog_desc.
  ///
  /// In en, this message translates to:
  /// **'Before starting the Holy Rosary, you may offer this prayer for your general intentions.'**
  String get intention_dialog_desc;

  /// No description provided for @intention_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: I offer this Holy Rosary for the healing of my family, peace in the world, and guidance in my studies/work...'**
  String get intention_input_hint;

  /// No description provided for @pray_without_intention.
  ///
  /// In en, this message translates to:
  /// **'Pray without Intention'**
  String get pray_without_intention;

  /// No description provided for @start_with_intention.
  ///
  /// In en, this message translates to:
  /// **'Offer & Start'**
  String get start_with_intention;

  /// No description provided for @general_intention_title.
  ///
  /// In en, this message translates to:
  /// **'General Intentions'**
  String get general_intention_title;

  /// No description provided for @quick_chip_family.
  ///
  /// In en, this message translates to:
  /// **'Healing of Family'**
  String get quick_chip_family;

  /// No description provided for @quick_chip_peace.
  ///
  /// In en, this message translates to:
  /// **'World Peace'**
  String get quick_chip_peace;

  /// No description provided for @quick_chip_guidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance in Studies / Work'**
  String get quick_chip_guidance;

  /// No description provided for @guide_intention_section_title.
  ///
  /// In en, this message translates to:
  /// **'BEFORE STARTING THE ROSARY (GENERAL INTENTIONS)'**
  String get guide_intention_section_title;

  /// No description provided for @guide_intention_note.
  ///
  /// In en, this message translates to:
  /// **'This is most commonly done. Before making the Sign of the Cross or praying the Creed, you may offer the entire Rosary for your general intention.'**
  String get guide_intention_note;

  /// No description provided for @guide_intention_example_label.
  ///
  /// In en, this message translates to:
  /// **'SAMPLE PRAYER OF INTENTION:'**
  String get guide_intention_example_label;

  /// No description provided for @edit_intention.
  ///
  /// In en, this message translates to:
  /// **'Write / Edit Intention'**
  String get edit_intention;

  /// No description provided for @title_sign_of_cross.
  ///
  /// In en, this message translates to:
  /// **'The Sign of the Cross'**
  String get title_sign_of_cross;

  /// No description provided for @title_apostles_creed.
  ///
  /// In en, this message translates to:
  /// **'The Apostles\' Creed'**
  String get title_apostles_creed;

  /// No description provided for @title_our_father.
  ///
  /// In en, this message translates to:
  /// **'Our Father'**
  String get title_our_father;

  /// No description provided for @title_hail_mary.
  ///
  /// In en, this message translates to:
  /// **'Hail Mary'**
  String get title_hail_mary;

  /// No description provided for @title_glory_be.
  ///
  /// In en, this message translates to:
  /// **'Glory Be'**
  String get title_glory_be;

  /// No description provided for @title_fatima_prayer.
  ///
  /// In en, this message translates to:
  /// **'The Fatima Prayer'**
  String get title_fatima_prayer;

  /// No description provided for @title_salve_regina.
  ///
  /// In en, this message translates to:
  /// **'Hail, Holy Queen'**
  String get title_salve_regina;

  /// No description provided for @title_closing_prayer.
  ///
  /// In en, this message translates to:
  /// **'Let Us Pray'**
  String get title_closing_prayer;

  /// No description provided for @title_ending_sign_of_cross.
  ///
  /// In en, this message translates to:
  /// **'Ending — The Sign of the Cross'**
  String get title_ending_sign_of_cross;

  /// No description provided for @ordinal_1.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get ordinal_1;

  /// No description provided for @ordinal_2.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get ordinal_2;

  /// No description provided for @ordinal_3.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get ordinal_3;

  /// No description provided for @ordinal_4.
  ///
  /// In en, this message translates to:
  /// **'Fourth'**
  String get ordinal_4;

  /// No description provided for @ordinal_5.
  ///
  /// In en, this message translates to:
  /// **'Fifth'**
  String get ordinal_5;

  /// No description provided for @your_intention_label.
  ///
  /// In en, this message translates to:
  /// **'YOUR INTENTION:'**
  String get your_intention_label;

  /// No description provided for @active_badge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active_badge;

  /// No description provided for @decade_intention_title.
  ///
  /// In en, this message translates to:
  /// **'Specific Intention for this Mystery'**
  String get decade_intention_title;

  /// No description provided for @decade_intention_note.
  ///
  /// In en, this message translates to:
  /// **'If you have a specific intention for this mystery, you may offer it after announcing the Mystery:'**
  String get decade_intention_note;

  /// No description provided for @decade_intention_phrase.
  ///
  /// In en, this message translates to:
  /// **'\"I offer this mystery for...\"'**
  String get decade_intention_phrase;

  /// No description provided for @text_sign_of_cross.
  ///
  /// In en, this message translates to:
  /// **'In the name of the Father, and of the Son, and of the Holy Spirit. Amen.'**
  String get text_sign_of_cross;

  /// No description provided for @text_apostles_creed.
  ///
  /// In en, this message translates to:
  /// **'I believe in God, the Father Almighty, Creator of heaven and earth, and in Jesus Christ, His only Son, our Lord, who was conceived by the Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, was crucified, died and was buried; He descended into hell; on the third day He rose again from the dead; He ascended into heaven, and is seated at the right hand of God the Father Almighty; from there He will come to judge the living and the dead. I believe in the Holy Spirit, the holy catholic Church, the communion of saints, the forgiveness of sins, the resurrection of the body, and life everlasting. Amen.'**
  String get text_apostles_creed;

  /// No description provided for @text_our_father.
  ///
  /// In en, this message translates to:
  /// **'Our Father, who art in heaven, hallowed be Thy name; Thy kingdom come; Thy will be done on earth as it is in heaven. Give us this day our daily bread; and forgive us our trespasses as we forgive those who trespass against us; and lead us not into temptation, but deliver us from evil. Amen.'**
  String get text_our_father;

  /// No description provided for @text_hail_mary.
  ///
  /// In en, this message translates to:
  /// **'Hail Mary, full of grace, the Lord is with thee; blessed art thou among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen.'**
  String get text_hail_mary;

  /// No description provided for @text_glory_be.
  ///
  /// In en, this message translates to:
  /// **'Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen.'**
  String get text_glory_be;

  /// No description provided for @text_fatima.
  ///
  /// In en, this message translates to:
  /// **'O my Jesus, forgive us our sins, save us from the fires of hell, and lead all souls to heaven, especially those in most need of Thy mercy. Amen.'**
  String get text_fatima;

  /// No description provided for @text_salve_regina.
  ///
  /// In en, this message translates to:
  /// **'Hail, Holy Queen, Mother of Mercy, hail, our life, our sweetness and our hope. To thee do we cry, poor banished children of Eve; to thee do we send up our sighs, mourning and weeping in this valley of tears. Turn then, most gracious advocate, thine eyes of mercy toward us, and after this our exile, show unto us the blessed fruit of thy womb, Jesus. O clement, O loving, O sweet Virgin Mary.\n\nPray for us, O holy Mother of God. That we may be made worthy of the promises of Christ.'**
  String get text_salve_regina;

  /// No description provided for @text_closing_prayer.
  ///
  /// In en, this message translates to:
  /// **'O God, whose only begotten Son, by His life, death, and resurrection, has purchased for us the rewards of eternal life, grant, we beseech Thee, that meditating upon these mysteries of the Most Holy Rosary of the Blessed Virgin Mary, we may imitate what they contain and obtain what they promise, through the same Christ our Lord. Amen.'**
  String get text_closing_prayer;

  /// No description provided for @text_ending_tts.
  ///
  /// In en, this message translates to:
  /// **'In the name of the Father, and of the Son, and of the Holy Spirit. Amen. We have finished praying the Holy Rosary. Thanks be to God.'**
  String get text_ending_tts;

  /// No description provided for @mystery_set_joyful.
  ///
  /// In en, this message translates to:
  /// **'Joyful Mysteries'**
  String get mystery_set_joyful;

  /// No description provided for @mystery_set_sorrowful.
  ///
  /// In en, this message translates to:
  /// **'Sorrowful Mysteries'**
  String get mystery_set_sorrowful;

  /// No description provided for @mystery_set_glorious.
  ///
  /// In en, this message translates to:
  /// **'Glorious Mysteries'**
  String get mystery_set_glorious;

  /// No description provided for @mystery_set_luminous.
  ///
  /// In en, this message translates to:
  /// **'Luminous Mysteries'**
  String get mystery_set_luminous;

  /// No description provided for @mystery_display_joyful.
  ///
  /// In en, this message translates to:
  /// **'Joyful'**
  String get mystery_display_joyful;

  /// No description provided for @mystery_display_sorrowful.
  ///
  /// In en, this message translates to:
  /// **'Sorrowful'**
  String get mystery_display_sorrowful;

  /// No description provided for @mystery_display_glorious.
  ///
  /// In en, this message translates to:
  /// **'Glorious'**
  String get mystery_display_glorious;

  /// No description provided for @mystery_display_luminous.
  ///
  /// In en, this message translates to:
  /// **'Luminous'**
  String get mystery_display_luminous;

  /// No description provided for @mystery_day_joyful.
  ///
  /// In en, this message translates to:
  /// **'Monday and Saturday'**
  String get mystery_day_joyful;

  /// No description provided for @mystery_day_sorrowful.
  ///
  /// In en, this message translates to:
  /// **'Tuesday and Friday'**
  String get mystery_day_sorrowful;

  /// No description provided for @mystery_day_glorious.
  ///
  /// In en, this message translates to:
  /// **'Wednesday and Sunday'**
  String get mystery_day_glorious;

  /// No description provided for @mystery_day_luminous.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get mystery_day_luminous;

  /// No description provided for @joyful_1.
  ///
  /// In en, this message translates to:
  /// **'The Annunciation of the Lord'**
  String get joyful_1;

  /// No description provided for @joyful_2.
  ///
  /// In en, this message translates to:
  /// **'The Visitation of Mary to Elizabeth'**
  String get joyful_2;

  /// No description provided for @joyful_3.
  ///
  /// In en, this message translates to:
  /// **'The Nativity of our Lord'**
  String get joyful_3;

  /// No description provided for @joyful_4.
  ///
  /// In en, this message translates to:
  /// **'The Presentation of Jesus in the Temple'**
  String get joyful_4;

  /// No description provided for @joyful_5.
  ///
  /// In en, this message translates to:
  /// **'The Finding of Jesus in the Temple'**
  String get joyful_5;

  /// No description provided for @sorrowful_1.
  ///
  /// In en, this message translates to:
  /// **'The Agony in the Garden'**
  String get sorrowful_1;

  /// No description provided for @sorrowful_2.
  ///
  /// In en, this message translates to:
  /// **'The Scourging at the Pillar'**
  String get sorrowful_2;

  /// No description provided for @sorrowful_3.
  ///
  /// In en, this message translates to:
  /// **'The Crowning with Thorns'**
  String get sorrowful_3;

  /// No description provided for @sorrowful_4.
  ///
  /// In en, this message translates to:
  /// **'The Carrying of the Cross'**
  String get sorrowful_4;

  /// No description provided for @sorrowful_5.
  ///
  /// In en, this message translates to:
  /// **'The Crucifixion and Death of our Lord'**
  String get sorrowful_5;

  /// No description provided for @glorious_1.
  ///
  /// In en, this message translates to:
  /// **'The Resurrection'**
  String get glorious_1;

  /// No description provided for @glorious_2.
  ///
  /// In en, this message translates to:
  /// **'The Ascension'**
  String get glorious_2;

  /// No description provided for @glorious_3.
  ///
  /// In en, this message translates to:
  /// **'The Descent of the Holy Spirit'**
  String get glorious_3;

  /// No description provided for @glorious_4.
  ///
  /// In en, this message translates to:
  /// **'The Assumption of Mary into Heaven'**
  String get glorious_4;

  /// No description provided for @glorious_5.
  ///
  /// In en, this message translates to:
  /// **'The Coronation of Mary as Queen of Heaven and Earth'**
  String get glorious_5;

  /// No description provided for @luminous_1.
  ///
  /// In en, this message translates to:
  /// **'The Baptism of Jesus in the Jordan'**
  String get luminous_1;

  /// No description provided for @luminous_2.
  ///
  /// In en, this message translates to:
  /// **'The Wedding at Cana'**
  String get luminous_2;

  /// No description provided for @luminous_3.
  ///
  /// In en, this message translates to:
  /// **'The Proclamation of the Kingdom'**
  String get luminous_3;

  /// No description provided for @luminous_4.
  ///
  /// In en, this message translates to:
  /// **'The Transfiguration'**
  String get luminous_4;

  /// No description provided for @luminous_5.
  ///
  /// In en, this message translates to:
  /// **'The Institution of the Eucharist'**
  String get luminous_5;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tl':
      return AppLocalizationsTl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
