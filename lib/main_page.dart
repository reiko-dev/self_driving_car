import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_driving_car/model/race_controller.dart';
import 'package:self_driving_car/ui/race.dart';
import 'package:self_driving_car/ui/network_visualizer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RaceController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFa9a9a9),
        appBar: AppBar(
          title: const Text("Self Driving Car Flutter"),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Race(),
            Expanded(
              child: SizedBox(
                child: MainButtons(),
              ),
            ),
            NetworkVisualizer(),
          ],
        ),
      ),
    );
  }
}

class MainButtons extends StatelessWidget {
  const MainButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            context.read<RaceController>().saveBrain();
          },
          child: const Text("Save"),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<RaceController>().discardBrain();
          },
          child: const Text("Discard"),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<RaceController>().generateJson();
          },
          child: const Text("Generate .json"),
        ),
        Consumer<RaceController>(
          builder: (context, value, child) {
            final json = value.json;
            if (json == null) {
              return child!;
            }
            return Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "JSON",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: SelectableText(
                            json,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                            toolbarOptions: const ToolbarOptions(
                              copy: true,
                              selectAll: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          child: const Spacer(),
        ),
        const Spacer(),
      ],
    );
  }
}
