import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String phoneNumber;

  WeatherPage({required this.phoneNumber, required this.userData});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey = "6427a9007eca4f33bb4173342240112";
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final String city = widget.userData['village'];
    final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        print("Failed to fetch weather data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade800,
        title: Text("Weather App", style: TextStyle(color: Colors.green.shade900)),
        centerTitle: true,
      ),
      body: weatherData == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade200, Colors.green.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Weather Information Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        weatherData!['location']['name'],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Image.network(
                        'https:${weatherData!['current']['condition']['icon']}',
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${weatherData!['current']['temp_c']}°C",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow.shade800,
                        ),
                      ),
                      Text(
                        weatherData!['current']['condition']['text'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Weather Info Tiles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WeatherInfoTile(
                    icon: Icons.water_drop_outlined,
                    title: "Humidity",
                    value: "${weatherData!['current']['humidity']}%",
                    backgroundColor: Colors.yellow.shade100,
                  ),
                  WeatherInfoTile(
                    icon: Icons.wind_power_outlined,
                    title: "Wind",
                    value: "${weatherData!['current']['wind_kph']} km/h",
                    backgroundColor: Colors.green.shade100,
                  ),
                  WeatherInfoTile(
                    icon: Icons.thermostat_outlined,
                    title: "Pressure",
                    value: "${weatherData!['current']['pressure_mb']} hPa",
                    backgroundColor: Colors.yellow.shade100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color backgroundColor;

  WeatherInfoTile({required this.icon, required this.title, required this.value, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: backgroundColor,
          child: Icon(icon, size: 28, color: Colors.green.shade900),
        ),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.green.shade700),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow.shade800),
        ),
      ],
    );
  }
}
