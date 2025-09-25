class KD {
  static const String api = 'http://13.204.87.75:7000/api';

  // Use the API like this
  //'${KD.api}/<rest content>' ---> e.g '${KD.api}/admin/fetch_mandi_rates'
  //bascially KD.api  = http://13.233.103.50:7000/api

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };
}