enum MysteryType { joyful, sorrowful, glorious, luminous }

extension MysteryTypeExtension on MysteryType {
  String getSetName(String lang) {
    if (lang == 'en') {
      switch (this) {
        case MysteryType.joyful:
          return 'Joyful Mysteries';
        case MysteryType.sorrowful:
          return 'Sorrowful Mysteries';
        case MysteryType.glorious:
          return 'Glorious Mysteries';
        case MysteryType.luminous:
          return 'Luminous Mysteries';
      }
    } else {
      switch (this) {
        case MysteryType.joyful:
          return 'Misteryo ng Kasayahan';
        case MysteryType.sorrowful:
          return 'Misteryo ng Hapis';
        case MysteryType.glorious:
          return 'Misteryo ng Kaluwalhatian';
        case MysteryType.luminous:
          return 'Misteryo ng Liwanag';
      }
    }
  }

  String getDisplayName(String lang) {
    if (lang == 'en') {
      switch (this) {
        case MysteryType.joyful:
          return 'Joyful';
        case MysteryType.sorrowful:
          return 'Sorrowful';
        case MysteryType.glorious:
          return 'Glorious';
        case MysteryType.luminous:
          return 'Luminous';
      }
    } else {
      switch (this) {
        case MysteryType.joyful:
          return 'Kasayahan';
        case MysteryType.sorrowful:
          return 'Hapis';
        case MysteryType.glorious:
          return 'Kaluwalhatian';
        case MysteryType.luminous:
          return 'Liwanag';
      }
    }
  }

  String get emoji {
    switch (this) {
      case MysteryType.joyful:
        return '🌸';
      case MysteryType.sorrowful:
        return '✝️';
      case MysteryType.glorious:
        return '✨';
      case MysteryType.luminous:
        return '💡';
    }
  }

  String getDayText(String lang) {
    if (lang == 'en') {
      switch (this) {
        case MysteryType.joyful:
          return 'Monday and Saturday';
        case MysteryType.sorrowful:
          return 'Tuesday and Friday';
        case MysteryType.glorious:
          return 'Wednesday and Sunday';
        case MysteryType.luminous:
          return 'Thursday';
      }
    } else {
      switch (this) {
        case MysteryType.joyful:
          return 'Lunes at Sabado';
        case MysteryType.sorrowful:
          return 'Martes at Biyernes';
        case MysteryType.glorious:
          return 'Miyerkules at Linggo';
        case MysteryType.luminous:
          return 'Huwebes';
      }
    }
  }

  List<String> getMysteryNames(String lang) {
    if (lang == 'en') {
      switch (this) {
        case MysteryType.joyful:
          return [
            'The Annunciation of the Lord',
            'The Visitation of Mary to Elizabeth',
            'The Nativity of our Lord',
            'The Presentation of Jesus in the Temple',
            'The Finding of Jesus in the Temple',
          ];
        case MysteryType.sorrowful:
          return [
            'The Agony in the Garden',
            'The Scourging at the Pillar',
            'The Crowning with Thorns',
            'The Carrying of the Cross',
            'The Crucifixion and Death of our Lord',
          ];
        case MysteryType.glorious:
          return [
            'The Resurrection',
            'The Ascension',
            'The Descent of the Holy Spirit',
            'The Assumption of Mary into Heaven',
            'The Coronation of Mary as Queen of Heaven and Earth',
          ];
        case MysteryType.luminous:
          return [
            'The Baptism of Jesus in the Jordan',
            'The Wedding at Cana',
            'The Proclamation of the Kingdom',
            'The Transfiguration',
            'The Institution of the Eucharist',
          ];
      }
    } else {
      switch (this) {
        case MysteryType.joyful:
          return [
            'Ang Pagpapahayag ng Anghel kay Maria',
            'Ang Pagdalaw ni Maria kay Santa Isabel',
            'Ang Kapanganakan ng ating Panginoon',
            'Ang Paghahandog kay Jesus sa Templo',
            'Ang Pagkawala at Pagkita kay Jesus sa Templo',
          ];
        case MysteryType.sorrowful:
          return [
            'Ang Paghihirap ni Jesus sa Halamanan ng Getsemani',
            'Ang Paghahagupit kay Jesus sa Haligi',
            'Ang Pagpuputong ng Koronang Tinik',
            'Ang Pagpapasan ni Jesus ng Krus',
            'Ang Pagpapako sa Krus at Pagkamatay ni Jesus',
          ];
        case MysteryType.glorious:
          return [
            'Ang Pagkabuhay ng ating Panginoon',
            'Ang Pag-akyat ni Jesus sa Langit',
            'Ang Pagbaba ng Espiritu Santo sa mga Apostol',
            'Ang Pag-akyat ng Mahal na Birhen Maria sa Langit nang Walang Kamatayan',
            'Ang Pagkokorona sa Mahal na Birhen Maria bilang Reyna ng Langit at Lupa',
          ];
        case MysteryType.luminous:
          return [
            'Ang Pagbibinyag kay Kristo',
            'Ang Kasalan sa Cana',
            'Ang Pagpapahayag ng Paghahari ng Diyos',
            'Ang Pagbabagong Anyo ni Kristo',
            'Ang Pagtatatag ng Eukaristiya',
          ];
      }
    }
  }
}
