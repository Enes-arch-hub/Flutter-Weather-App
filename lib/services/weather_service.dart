import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService{
  static const String baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService({ required this.apiKey});

  //get weather
Future<Weather> getWeather(String cityName) async{
  final response = await http.get(Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'));
  if(response.statusCode == 200){
    return Weather.fromJson(jsonDecode(response.body));
  } else{
  throw Exception('Failed to load weather data');
  }
  }
//get current weather city by name
Future<String> getCurrentCity() async {
  //get permission from user
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied){
    permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.denied){
      throw Exception ('Location permission denied');
    }
  }
  //fetch current location
  Position position = await Geolocator.getCurrentPosition(
    locationSettings: LocationSettings(accuracy: LocationAccuracy.high)
  );
  //convert loaction into list of place mark objects
  List<Placemark> placemark = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  //extract city name from place mark object
  String? city = placemark [0].locality;

  return city ?? 'Unknown';

}
}