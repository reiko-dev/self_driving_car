import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:self_driving_car/controller/model/car.dart';
import 'package:self_driving_car/controller/model/network.dart';
import 'package:self_driving_car/ui/road.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RaceController with ChangeNotifier {
  RaceController()
      : _numberOfAICars = 10,
        _mutationFactor = .2;

  final aisNumberTextController = TextEditingController();
  final mutationFactorTextController = TextEditingController();
  int _numberOfAICars;
  double _mutationFactor;

  late Road road;
  SharedPreferences? prefs;

  List<Car> traffic = [];

  late Car bestCar;
  List<Car> cars = [];
  bool isLoading = true;

  String? json;

  Future<void> init(Road road) async {
    isLoading = true;
    this.road = road;

    prefs = await SharedPreferences.getInstance();

    aisNumberTextController.text = "$_numberOfAICars";
    mutationFactorTextController.text = "$_mutationFactor";
    generateTraffic();

    cars = generateCars(_numberOfAICars);
    bestCar = cars[0];
    loadBrain();
    isLoading = false;
    notifyListeners();
  }

  void reload() {
    traffic.clear();
    cars.clear();
    init(road);
  }

  void generateTraffic() {
    traffic.addAll([
      Car(x: road.getLaneCenter(1), y: -70, maxSpeed: 2),
      Car(x: road.getLaneCenter(0), y: -270, maxSpeed: 2),
      Car(x: road.getLaneCenter(2), y: -270, maxSpeed: 2),
      Car(x: road.getLaneCenter(1), y: -470, maxSpeed: 2),
      Car(x: road.getLaneCenter(2), y: -470, maxSpeed: 2),
      Car(x: road.getLaneCenter(0), y: -670, maxSpeed: 2),
      Car(x: road.getLaneCenter(1), y: -700, maxSpeed: 2),
      Car(x: road.getLaneCenter(1), y: -895, maxSpeed: 2),
      Car(x: road.getLaneCenter(2), y: -870, maxSpeed: 2),
      Car(x: road.getLaneCenter(0), y: -1035, maxSpeed: 2.1),
      Car(x: road.getLaneCenter(2), y: -1030, maxSpeed: 2.1),
      Car(x: road.getLaneCenter(1), y: -1190, maxSpeed: 2.1),
      Car(x: road.getLaneCenter(0), y: -1400, maxSpeed: 2.1),
      Car(x: road.getLaneCenter(1), y: -1400, maxSpeed: 2.1),
      Car(x: road.getLaneCenter(2), y: -1400, maxSpeed: 2.1),
    ]);
  }

  set numberOfAICars(int newNumber) {
    if (newNumber > 0 && newNumber != _numberOfAICars) {
      _numberOfAICars = newNumber;
      aisNumberTextController.text = "$_numberOfAICars";
    }
  }

  ///Must be a number between 0 and 1.
  set mutationFactor(double newFactor) {
    if (newFactor < 0 || newFactor > 1) return;

    if (newFactor != _mutationFactor) {
      _mutationFactor = newFactor;
      mutationFactorTextController.text = "$_mutationFactor";
    }
  }

  loadBrain() {
    final String? data = prefs!.getString('bestBrain');

    if (data == null) return;
    bestCar.brain = NeuralNetwork.fromJson(jsonDecode(data));

    for (var i = 0; i < cars.length; i++) {
      cars[i].brain = bestCar.brain!.copyWith();
      if (i != 0) {
        NeuralNetwork.mutate(cars[i].brain!, amount: _mutationFactor);
      }
    }
  }

  void saveBrain() async {
    await prefs!.setString('bestBrain', jsonEncode(bestCar.brain!.toJson()));
    debugPrint('The new brain is safe!!');
  }

  discardBrain() async {
    await prefs!.clear();
    debugPrint('Storage is clear.');
  }

  void generateJson() {
    json = jsonEncode(bestCar.brain!.toJson());
    notifyListeners();
  }

  List<Car> generateCars(n) {
    final cars = <Car>[];

    for (var i = 1; i <= n; i++) {
      cars.add(
        Car(x: road.getLaneCenter(1), y: 100, controlType: ControlType.ia),
      );
    }

    return cars;
  }

  bool isDeadBrain(Car car) {
    if (car.isDamaged) {
      return cars.length > 20;
    }
    return false;
  }

  void animate() {
    for (var i = 0; i < traffic.length; i++) {
      traffic[i].update(road.borders, []);
    }

    for (var i = 0; i < cars.length; i++) {
      if (isDeadBrain(cars[i])) {
        cars.removeAt(i);
      } else {
        cars[i].update(road.borders, traffic);
      }
    }

    late double fasterCarYPosition = cars[0].y;

    //TODO: define others fitness functions
    //One could be the way the car has run
    //Other their average velocity and so on...
    for (var c in cars) {
      if (c.y < fasterCarYPosition) {
        fasterCarYPosition = c.y;
      }
    }

    bestCar = cars.firstWhere((c) => c.y == fasterCarYPosition);
  }
}
