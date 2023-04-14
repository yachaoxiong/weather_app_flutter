import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Weather App')),
        body: WeatherApp(),
      ),
    );
  }
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String apiKey = '3c074d5b7cb6c3257d75b40ec13b8ed3';
  TextEditingController _cityController = TextEditingController();
  String cityName = '';
  String? temperature;
  String? weatherDescription;
  LatLng? location;

  Future<void> _getWeatherData(String city) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        cityName = data['name'];
        temperature = data['main']['temp'].toString();
        weatherDescription = data['weather'][0]['description'];
        location = LatLng(data['coord']['lat'], data['coord']['lon']);
      });
    } else {
      print('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'Enter city name',
            ),
          ),
          ElevatedButton(
            onPressed: () => _getWeatherData(_cityController.text),
            child: Text('Get Weather Data'),
          ),
          SizedBox(height: 16),
          if (cityName.isNotEmpty) ...[
            Text('City: $cityName', style: TextStyle(fontSize: 18)),
            Text('Temperature: $temperature°C', style: TextStyle(fontSize: 18)),
            Text('Weather: $weatherDescription',
                style: TextStyle(fontSize: 18)),
          ],
          SizedBox(height: 16),
          if (location != null) ...[
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location!,
                  zoom: 12,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('cityMarker'),
                    position: location!,
                    infoWindow: InfoWindow(title: cityName),
                  ),
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
