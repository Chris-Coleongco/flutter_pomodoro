import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

final _formKey = GlobalKey<FormState>();

bool _isActive = true;
int savedWorkOnTime = 0;
int savedRestTime = 0;
String savedAvatar = '';

String durationTypeA = '';
_retrieveTimerInfo() async {
  final prefs = await SharedPreferences.getInstance();
  savedWorkOnTime = prefs.getInt('workOnTime') ?? -1;
  savedRestTime = prefs.getInt('restTime') ?? -1;
  savedAvatar = prefs.getString('avatar') ?? 'not found';

  print(savedWorkOnTime);
  print(savedRestTime);
  print(savedAvatar);
}

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
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    int difference = await runTimer();
    if (difference % (savedWorkOnTime + savedRestTime) == 0) {
      print('divisible');
    } else if (difference % (savedWorkOnTime + savedRestTime) != 0) {
      int remainder = difference % (savedWorkOnTime + savedRestTime);

      if (_isActive == true) {
        if (remainder <= savedWorkOnTime) {
          durationTypeA = 'work';
        } else if (remainder > savedWorkOnTime) {
          durationTypeA = 'rest';
        }

        print(durationTypeA);
      }
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
                CurrentTimer(),
              ],
            )
          : currentPage == 1
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Title(
                        color: Colors.black, child: const Text('timer setup')),
                    const SizedBox(height: 20),
                    FormWidget(),
                  ],
                )
              : SizedBox(),
      bottomNavigationBar: NavigationBar(
        destinations: [
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
  int savedWorkOnTime = 0;
  int savedRestTime = 0;
  String savedAvatar = '';

  String durationType = '';

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
    _retrieveTimerInfo();
    setState(() {
      durationType = durationTypeA;
    });
  }

  Widget build(BuildContext context) {
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    // USE A STREAM BUILDER
    /*StreamBuilder<int>(
      stream: myStream, // Your stream instance
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        // Build your UI based on the stream's data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final data = snapshot.data;
          return Text('Data: $data');
        }
      },
    ); */

    return Center(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                durationType == 'work'
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('get to work!'),
                          //image changes go here
                          Image(image: AssetImage('assets/eggs/chick-pio.gif'))
                        ],
                      )
                    : durationType == 'rest'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('take a break!'),
                              Image(image: AssetImage('assets/eggs/egg.gif'))
                            ],
                          )
                        : SizedBox(),
                ElevatedButton(
                    onPressed: () {
                      startTimer();
                      runTimerRecursive();
                      Timer.periodic(const Duration(seconds: 1), (timer) {
                        print('checked');
                        if (durationType == 'work') {
                          setState(() {
                            durationType = 'rest';
                          });
                        } else if (durationType == 'rest') {
                          setState(() {
                            durationType = 'work';
                          });
                        }
                      });
                    },
                    child: const Text('start timer'))
              ],
            )));
  }
}
