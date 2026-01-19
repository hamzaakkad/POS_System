// class Weather {
//   final String cityName;
//   final double temperature;
//   final String description;
//   final String iconUrl;

//   Weather({
//     required this.cityName,
//     required this.temperature,
//     required this.description,
//     required this.iconUrl,
//   });

//   factory Weather.fromJson(Map<String, dynamic> json) {
//     return Weather(
//       cityName: json['location']['name'],
//       temperature: (json['current']['temp_c'] as num).toDouble(),
//       description: json['current']['condition']['text'],
//       iconUrl: 'https:${json['current']['condition']['icon']}',
//     );
//   }
// }

class Weather {
  final String cityName;
  final double temperature;
  final String description;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
    );
  }
}
/*
class Weather {
  final String cityName;
  final double temperature;
  final String description;

  Weather({required this.cityName, required this.temperature, required this.description});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
    );
  }
}
*/