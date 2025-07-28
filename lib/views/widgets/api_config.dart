class KD {
  static const String api = 'http://13.233.103.50/api';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };
}

class MR {
  static const String api = 'http://13.233.103.50/api/admin/fetch_mandi_rates';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };
}
