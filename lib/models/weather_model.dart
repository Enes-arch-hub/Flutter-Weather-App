class Weather{
  final String cityName;
  final double temperature;
  final String mainCondition;
  final String iconCode;
  final int cloudPercentage;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.iconCode,
    required this.cloudPercentage,
});
  factory Weather.fromJson(Map<String, dynamic> json){
    return Weather(
      cityName: json['name'],
      temperature: json['main'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      cloudPercentage: json ['clouds']['all'],
    );
  }
}