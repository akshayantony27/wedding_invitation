/// Single source of truth for every piece of wedding content.
/// Wording below is taken verbatim from the invitation brief.
class WeddingConfig {
  WeddingConfig._();

  // People
  static const String groom = 'Akshay Antony';
  static const String bride = 'Wilma Theresa';
  static const String groomParents = 'Mr. George P D & Mrs. Metilda George';
  static const String brideParents = 'Mr. KG Edwin & Mrs. Hilda Edwin';

  // Wording
  static const String verse = 'I have found the one whom my soul loves';
  static const String verseReference = 'Song of Solomon 3:4';
  static const String blessingLine = 'With love and blessings from their parents,';
  static const String hostsUpper = 'MR. GEORGE P D & MRS. METILDA GEORGE';
  static const String inviteLine = 'Cordially invite you to celebrate the wedding of';
  static const String invitationMessage =
      'Mr. George P D & Mrs. Metilda George cordially invite you to grace the '
      'occasion with your presence and prayers at the wedding ceremony of our son.';

  // When
  static const String weekday = 'Sunday';
  static const String dateLong = 'Sunday, 27 December 2026';
  static const String timeLabel = '10:30 AM';

  /// 10:30 AM IST (UTC+05:30) == 05:00 UTC.
  static final DateTime weddingInstantUtc = DateTime.utc(2026, 12, 27, 5, 0);

  /// The wedding's calendar day in IST (used for "Today is the Day!").
  static final DateTime weddingDayIst = DateTime.utc(2026, 12, 27);
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  // Where
  static const String venueName = 'The Basilica of Our Lady of Ransom';
  static const String venueLocality = 'Vallarpadam, Kochi, Kerala';
  static const String venueFull =
      'The Basilica of Our Lady of Ransom, Vallarpadam, Kochi, Kerala, India';

  /// Church photograph asset path (Vallarpadam Basilica)
  static const String churchPhoto = 'assets/images/basilica_church.jpg';

  /// Opens Google Maps directions to the venue (Maps app on phones).
  static Uri get directionsUri => Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': venueFull,
      });

  /// "Add to calendar" link. End time is a placeholder (2 h after start).
  static Uri get calendarUri => Uri.https('calendar.google.com', '/calendar/render', {
        'action': 'TEMPLATE',
        'text': 'Wedding of $groom & $bride',
        'dates': '20261227T050000Z/20261227T070000Z',
        'location': venueFull,
        'details': invitationMessage,
      });
}
