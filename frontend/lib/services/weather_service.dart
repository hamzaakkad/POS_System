import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

// class WeatherService {
//   final String apiKey = '8fdbd438922c40b59b0155153251212';
//   final String baseUrl = 'https://api.weatherapi.com/v1'; // Changed to https

//   Future<Weather> fetchWeather(String city) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/current.json?key=$apiKey&q=$city&aqi=no'),
//       );

//       if (response.statusCode == 200) {
//         return Weather.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load weather: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch weather: $e');
//     }
//   }
// }

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

// Future<Weather> fetchWeather(String city) async {
//   final String apiKey = "173b6fe7e1c9bfca237399eecc7ed51e";
//   final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";
//   final url = '$baseUrl?q=$city&appid=$apiKey&units=metric';

//   print(' Weather request URL: $url');

//   final response = await http.get(Uri.parse(url));

//   print(' Status code: ${response.statusCode}');
//   print(' Response body: ${response.body}');

//   if (response.statusCode == 200) {
//     return Weather.fromJson(json.decode(response.body));
//   } else {
//     throw Exception('Failed to load weather data');
//   }
// }
