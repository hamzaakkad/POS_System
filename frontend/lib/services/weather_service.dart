import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';


class WeatherService {
  final String apiKey = "173b6fe7e1c9bfca237399eecc7ed51e";
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<Weather> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'),
    );
    //FOR TESTING PURPOSESSSSS
    print(' Status code: ${response.statusCode}');
    print(' Response body: ${response.body}');
    //print(response.body.toString());

    if (response.statusCode == 200) {
      // print(response.body.toString());

      // If the call was successful, parse the JSON
      return Weather.fromJson(json.decode(response.body));
    } else {
      // print(response.body.toString());

      // If that call was not successful, throw an error
      throw Exception('Failed to load weather data');
    }
  }
}

