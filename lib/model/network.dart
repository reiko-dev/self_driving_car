import 'dart:math';

import 'package:self_driving_car/utils.dart';

class NeuralNetwork {
  static final _rand = Random();
  final List<Level> levels;

  factory NeuralNetwork(List<int> neuronCounts) {
    final levels = <Level>[];
    for (var i = 0; i < neuronCounts.length - 1; i++) {
      levels.add(
        Level(neuronCounts[i], neuronCounts[i + 1]),
      );
    }

    return NeuralNetwork._init(levels);
  }

  factory NeuralNetwork._withLevels(List<Level> levels) {
    List<Level> r = [];
    for (var l in levels) {
      r.add(l.copyWith());
    }

    return NeuralNetwork._init(r);
  }

  factory NeuralNetwork.fromJson(Map<String, dynamic> json) {
    final list = json['levels'];
    final List<Level> levels = [];

    list.forEach((l) {
      levels.add(Level.fromJson(l));
    });

    return NeuralNetwork._init(levels);
  }

  NeuralNetwork._init(this.levels);

  Map<String, dynamic> toJson() => {
        'levels': levels.map((e) => e.toJson()).toList(),
      };

  NeuralNetwork copyWith() => NeuralNetwork._withLevels(levels);

  static feedForward(givenInputs, NeuralNetwork network) {
    var outputs = Level.feedForward(givenInputs, network.levels[0]);

    for (var i = 1; i < network.levels.length; i++) {
      outputs = Level.feedForward(outputs, network.levels[i]);
    }

    return outputs;
  }

  static void mutate(NeuralNetwork network, {double amount = 1}) {
    for (var level in network.levels) {
      for (var i = 0; i < level.biases.length; i++) {
        level.biases[i] = lerp(
          level.biases[i],
          _rand.nextDouble() * 2 - 1,
          amount,
        );
      }

      for (var i = 0; i < level.weights.length; i++) {
        for (var j = 0; j < level.weights[i].data.length; j++) {
          level.weights[i].data[j] = lerp(
            level.weights[i].data[j],
            _rand.nextDouble() * 2 - 1,
            amount,
          );
        }
      }
    }
  }

  @override
  String toString() {
    return "NeuralNetwork: $levels";
  }
}

class Level {
  static final rand = Random();

  final List<double> inputs;
  final List<double> outputs;
  final List<double> biases;
  final List<Weight> weights;

  factory Level(int inputCount, int outputCount) {
    final inputs = List<double>.filled(inputCount, 0);
    final outputs = List<double>.filled(outputCount, 0);
    final biases = List<double>.filled(outputCount, 0);

    final weights = <Weight>[];

    for (var i = 0; i < inputCount; i++) {
      weights.add(Weight(outputCount));
    }

    return Level._(
        biases: biases, inputs: inputs, outputs: outputs, weights: weights);
  }

  Level._({
    required this.biases,
    required this.inputs,
    required this.outputs,
    required this.weights,
    bool randomize = true,
  }) {
    if (randomize) {
      _randomize(this);
    }
  }

  Level.fromJson(Map<String, dynamic> json)
      : biases = List<double>.from(json['biases']),
        inputs = List<double>.from(json['inputs']),
        outputs = List<double>.from(json['outputs']),
        weights = json['weights']
            .map<Weight>((json) => Weight.fromJson(json))
            .toList();

  Map<String, dynamic> toJson() => {
        'biases': biases,
        'inputs': inputs,
        'outputs': outputs,
        'weights': weights,
      };

  Level copyWith() {
    final r = weights.map<Weight>((e) => e.copyWith()).toList();

    return Level._(
      biases: biases.toList(),
      inputs: inputs.toList(),
      outputs: outputs.toList(),
      weights: r,
      randomize: false,
    );
  }

  static _randomize(Level level) {
    for (var i = 0; i < level.inputs.length; i++) {
      for (var j = 0; j < level.outputs.length; j++) {
        level.weights[i].data[j] = rand.nextDouble() * 2 - 1;
      }
    }

    for (var i = 0; i < level.biases.length; i++) {
      level.biases[i] = rand.nextDouble() * 2 - 1;
    }
  }

  static feedForward(List givenInputs, Level level) {
    for (var i = 0; i < level.inputs.length; i++) {
      level.inputs[i] = givenInputs[i];
    }

    for (var i = 0; i < level.outputs.length; i++) {
      var sum = 0.0;
      for (var j = 0; j < level.inputs.length; j++) {
        sum += level.inputs[j] * level.weights[j].data[i];
      }

      if (sum > level.biases[i]) {
        level.outputs[i] = 1;
      } else {
        level.outputs[i] = 0;
      }
    }

    return level.outputs;
  }

  @override
  String toString() {
    return "(Level: biases: $biases, inputs: $inputs, outputs: $outputs, weights: $weights)";
  }
}

class Weight {
  final List<double> data;

  Weight(itemsCount) : data = List<double>.filled(itemsCount, 0);

  Weight._(this.data);

  Weight.fromJson(Map<String, dynamic> json)
      : data = List<double>.from(json["data"]);

  Map<String, dynamic> toJson() => {"data": data};

  Weight copyWith() => Weight._(data.toList());

  @override
  String toString() {
    return "(Weight: $data)";
  }
}
