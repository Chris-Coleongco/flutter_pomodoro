import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

final _formKey = GlobalKey<FormState>();

StreamController<String> _durationTypeController =
    StreamController<String>.broadcast();
Stream<String> get durationTypeStream => _durationTypeController.stream;

StreamController<int> _remainderController = StreamController<int>.broadcast();
Stream<int> get remainderStream => _remainderController.stream;

_retrieveTimerInfo() async {
  final prefs = await SharedPreferences.getInstance();
  savedWorkOnTime = prefs.getInt('workOnTime') ?? -1;
  savedRestTime = prefs.getInt('restTime') ?? -1;
  savedAvatar = prefs.getString('avatar') ?? 'not found';

  print(savedWorkOnTime);
  print(savedRestTime);
  print(savedAvatar);

  List<dynamic> timerInfo = [savedWorkOnTime, savedRestTime, savedAvatar];

  return timerInfo;
}

List<dynamic> timerInfo = _retrieveTimerInfo();

bool _isActive = true;
int savedWorkOnTime = timerInfo[0];
int savedRestTime = timerInfo[1];
String savedAvatar = timerInfo[2];
bool stopButtonClicked = false;
String durationTypeA = '';

startTimer() async {
  final startTime = DateTime.now().toString();
  //final b = DateTime.parse(startTime);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('startTime', startTime);
}

runTimer() async {
  final prefs = await SharedPreferences.getInstance();
  String old = prefs.getString('startTime') ?? 'invalid datetime error';

  final oldDateTime = DateTime.parse(old);

  final currentDateTime = DateTime.now();

  int difference = currentDateTime.difference(oldDateTime).inSeconds;

  print(difference);

  return difference;
}

runTimerRecursive() {
  Timer.periodic(const Duration(seconds: 1), (mainTimer) async {
    if (stopButtonClicked == false) {
      int difference = await runTimer();
      if (difference % (savedWorkOnTime + savedRestTime) == 0) {
        _remainderController.add(savedRestTime);
        print('divisible');
        durationTypeA = 'rest';
        print('SHOULD RETURN WORK');
        _durationTypeController.add(durationTypeA);
      } else if (difference % (savedWorkOnTime + savedRestTime) != 0) {
        int remainder = difference % (savedWorkOnTime + savedRestTime);
        if (remainder <= savedWorkOnTime) {
          durationTypeA = 'work';
          print('SHOULD RETURN WORK');
          _durationTypeController.add(durationTypeA);
        } else {
          durationTypeA = 'rest';
          print('SHOULD RETURN REST');
          _durationTypeController.add(durationTypeA);
        }

        print(durationTypeA);
        _remainderController.add(remainder);
      }
      print(_remainderController);
    } else {
      mainTimer.cancel();
    }
  });
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ParentWidget(),
    );
  }
}

class ParentWidget extends StatefulWidget {
  const ParentWidget({Key? key}) : super(key: key);

  @override
  _ParentWidgetState createState() {
    return _ParentWidgetState();
  }
}

class _ParentWidgetState extends State<ParentWidget> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Egg Timer'),
      ),
      body: currentPage == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Title(color: Colors.black, child: const Text('current timer')),
                const SizedBox(height: 20),
                const CurrentTimer(),
              ],
            )
          : currentPage == 1
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Title(
                        color: Colors.black, child: const Text('timer setup')),
                    const SizedBox(height: 20),
                    const FormWidget(),
                  ],
                )
              : const SizedBox(),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Create')
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;

            if (currentPage == 1) {
              _isActive = false;
            }

            if (currentPage == 0) {
              _isActive = true;
            }
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  const FormWidget({Key? key}) : super(key: key);

  @override
  _FormWidgetState createState() {
    return _FormWidgetState();
  }
}

class _FormWidgetState extends State<FormWidget> {
  int currentPage = 1;

  final items = ['egg'];

  int workOnTime = 0;

  int restTime = 0;

  String avatar = 'egg';

  _saveTimerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workOnTime', workOnTime);
    await prefs.setInt('restTime', restTime);
    await prefs.setString('avatar', avatar);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      key: _formKey,
      child: Column(children: [
        workOn(),
        const SizedBox(height: 20),
        rest(),
        const SizedBox(height: 20),
        avatarImg(),
        const SizedBox(height: 20),
        submitButton()
      ]),
    );
  }

  Widget workOn() => TextFormField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'work',
          border: OutlineInputBorder(),
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) => setState(() {
          workOnTime = int.parse(value);
          print(workOnTime);
        }),
      );

  Widget rest() => TextFormField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'rest',
        border: OutlineInputBorder(),
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      onChanged: (value) => setState(() {
            restTime = int.parse(value);
            print(restTime);
          }));

  Widget avatarImg() => DropdownButton(
      value: avatar,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items.map((String items) {
        return DropdownMenuItem(value: items, child: Text(items));
      }).toList(),
      onChanged: (String? value) => setState(() {
            avatar = value!;
            print(avatar);
          }));

  Widget submitButton() => ElevatedButton(
      onPressed: () {
        _saveTimerSettings();
      },
      child: const Text('set timer'));
}

class CurrentTimer extends StatefulWidget {
  const CurrentTimer({Key? key}) : super(key: key);

  @override
  _CurrentTimerWidgetState createState() {
    return _CurrentTimerWidgetState();
  }
}

class _CurrentTimerWidgetState extends State<CurrentTimer> {
  String durationType = '';
  bool startButtonHide = false;
  endTimer() {
    print('timer end');
  }

  //  _saveTimerSettings() async {
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setInt('workOnTime', workOnTime);
  //await prefs.setInt('restTime', restTime);
  //await prefs.setString('avatar', avatar);
  //}

  @override
  void initState() {
    super.initState();
    setState(() {
      durationType = durationTypeA;
    });
  }

  List<dynamic> timerInfo = [];

  getTimerInfo() async {
    timerInfo = await _retrieveTimerInfo();
    savedWorkOnTime = timerInfo[0];
    savedRestTime = timerInfo[1];
    savedAvatar = timerInfo[2];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<String>(
          stream: durationTypeStream,
          initialData: durationTypeA,
          builder: (context, snapshot) {
            final currentDurationType = snapshot.data ?? durationTypeA;

            print('Stream value: $currentDurationType');

            return Column(
              children: [
                currentDurationType == 'work'
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('get to work!'),
                          //image changes go here
                          Image(image: AssetImage('assets/eggs/chick-pio.gif'))
                        ],
                      )
                    : currentDurationType == 'rest'
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('take a break!'),
                              Image(image: AssetImage('assets/eggs/egg.gif'))
                            ],
                          )
                        : const SizedBox(),
                StreamBuilder<int>(
                  stream: remainderStream, // Replace with your remainder stream
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    int remainder = snapshot.data!;

                    int time = 0;

                    print('savedWorkOnTime $savedWorkOnTime');
                    print('savedRestTime $savedRestTime');

                    if (remainder <= savedWorkOnTime) {
                      time = remainder;
                      print(time);
                    } else {
                      time = remainder - savedWorkOnTime;
                      print(time);
                    }
                    return Text('$currentDurationType: $time');
                  },
                ),
                startButtonHide == false
                    ? ElevatedButton(
                        onPressed: () {
                          startTimer();
                          runTimerRecursive();
                          if (_isActive) {
                            // Toggle between 'work' and 'rest' when the button is pressed
                            if (currentDurationType == 'work') {
                              // Add the new value to the stream
                              _durationTypeController.add('rest');
                            } else if (currentDurationType == 'rest') {
                              // Add the new value to the stream
                              _durationTypeController.add('work');
                            }
                          }
                          setState(() {
                            startButtonHide = true;
                          });
                        },
                        child: const Text('start timer'),
                      )
                    : startButtonHide == true && stopButtonClicked == false
                        ? ElevatedButton(
                            onPressed: () {
                              stopButtonClicked = true;
                              // STOP THE TIMER
                            },
                            child: const Text('stop timer'))
                        : const SizedBox(),
              ],
            );
          },
        ),
      ),
    );
  }
}
