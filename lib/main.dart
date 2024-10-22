import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_number/sliding_number.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Counter',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: Colors.blueGrey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black12,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  List<int> _mainNumbers = [];
  List<String> _players = [];
  final List<int> _values = [1, 2, 3, 4, 5, 6, 7, 10];
  List<String> _log = [];

  @override
  void initState() {
    super.initState();
  }

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateMainNumber(int playerIndex, int? value) {
    setState(() {
      if (value != null) {
        _mainNumbers[playerIndex] += value;
        _log.add(
            '      ${_players[playerIndex]} :    ${value > 0 ? '+$value' : value}');
      } else {
        _log.add('      ${_players[playerIndex]} :    Reset');
        _mainNumbers[playerIndex] = 0;
      }
    });
  }

  void _showPlayerInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int playerCount = 1;
        final nameControllers = <TextEditingController>[
          TextEditingController()
        ];

        return AlertDialog(
          title: const Center(
            child: Text('Setup Game',style: TextStyle(
                fontFamily: "Dubai", color: Colors.blue,),),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (playerCount > 1) {
                                playerCount--;
                                if (nameControllers.length > playerCount) {
                                  nameControllers.removeRange(
                                      playerCount, nameControllers.length);
                                }
                              }
                            });
                          },
                        ),
                        Text(
                          '$playerCount',
                          style: const TextStyle(
                              fontFamily: "Dubai", fontSize: 50,color: Colors.blue),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              playerCount++;
                              if (nameControllers.length < playerCount) {
                                nameControllers.add(TextEditingController());
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    ...List.generate(playerCount, (index) {
                      return TextField(
                        controller: nameControllers[index],
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                              fontFamily: "Dubai"
                          ),
                          labelText: 'Player ${index + 1} Name',
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _log.add(
                    '                   New Game Started');
                setState(() {
                  _players = nameControllers
                      .map((controller) => controller.text)
                      .toList();
                  _mainNumbers = List.generate(_players.length, (_) => 0);
                });

                Navigator.of(context).pop();

              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerCounter(int playerIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousPage,
              icon: const Icon(
                Icons.chevron_left,
                size: 50,
              ),
            ),
            Text(
              _players[playerIndex],
              style: const TextStyle(
                  fontFamily: "Dubai",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            IconButton(
                onPressed: _nextPage,
                icon: const Icon(
                  Icons.chevron_right,
                  size: 50,
                )),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SlidingNumber(
                number: _mainNumbers[playerIndex],
                style: const TextStyle(
                    fontFamily: "Dubai",
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeOutQuint,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        children: _values.map((value) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ZoomTapAnimation(
                              child: TextButton(
                                onPressed: () =>
                                    _updateMainNumber(playerIndex, value),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: Text('+$value',
                                    style: const TextStyle(
                                        fontFamily: "Dubai", fontSize: 30)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: _values.map((value) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ZoomTapAnimation(
                              child: TextButton(
                                onPressed: () =>
                                    _updateMainNumber(playerIndex, -value),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: Text('-$value',
                                    style: const TextStyle(
                                        fontFamily: "Dubai", fontSize: 30)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Feedback',
            style: TextStyle(fontFamily: "Dubai", fontSize: 16),
          ),
          content: TextField(
            controller: feedbackController,
            decoration: const InputDecoration(hintText: "Enter your feedback here"),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'About Snooker Score Counter',
            style: TextStyle(fontFamily: "Dubai", fontSize: 16),
          ),
          content: const Text(
            'This app helps you keep track of snooker scores.',
            style: TextStyle(fontFamily: "Dubai", fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _exitApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.blue, // Set the hamburger icon color to blue
        ),
        title: const Center(
          child: Text(
            'Snooker Score Counter',
            style: TextStyle(
                fontFamily: "Dubai", color: Colors.blue, fontSize: 18),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case '1':
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showPlayerInputDialog();
                  });
                  break;
                case '2':
                  _showFeedbackDialog();
                  break;
                case '3':
                  _showAboutDialog();
                  break;
                case '4':
                  _exitApp();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: '1',
                  child: Text('New Game',style: TextStyle(
                      fontFamily: "Dubai", color: Colors.blue, fontSize: 10),),
                ),
                const PopupMenuItem<String>(
                  value: '2',
                  child: Text('FeedBack',style: TextStyle(
                      fontFamily: "Dubai", color: Colors.blue, fontSize: 10),),
                ),
                const PopupMenuItem<String>(
                  value: '3',
                  child: Text('About',style: TextStyle(
                      fontFamily: "Dubai", color: Colors.blue, fontSize: 10),),
                ),
                const PopupMenuItem<String>(
                  value: '4',
                  child: Text('Exit',style: TextStyle(
                      fontFamily: "Dubai", color: Colors.red, fontSize: 10),),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 25,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Game Logs',
                style: TextStyle(
                  fontFamily: "Dubai",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const Divider(color: Colors.blue),
            _players.isEmpty
                ?

            Column(
              children: [
                const SizedBox(height: 50,),
                const Text(
                  "Add players to see Logs",
                  style: TextStyle(
                    fontFamily: "Dubai",
                  ),
                ),
                const SizedBox(height: 30,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showPlayerInputDialog,
                        child: const Text(
                          "Add players",
                          style: TextStyle(
                            fontFamily: "Dubai",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )


                : Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _log.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _log.length - 1 - index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      _log[reversedIndex],
                      style: const TextStyle(
                        fontFamily: "Dubai",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
      body: _players.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Column(
                        children: [
                          const Text(
                            "147",
                            style: TextStyle(
                                fontFamily: "Dubai",
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 20,),
                          Image.asset(
                            'assets/splash_image.png',
                            width: 300,
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'No players added.',
                      style: TextStyle(
                          fontFamily: "Dubai",
                          color: Colors.white,
                          fontSize: 24),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showPlayerInputDialog,
                            child: const Text(
                              "Add players",
                              style: TextStyle(
                                fontFamily: "Dubai",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : PageView.builder(
              controller: _pageController,
              itemCount: _players.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPlayerCounter(index),
                );
              },
            ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CounterScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const SlidingNumber(
            number: 147,
            style: TextStyle(
                fontFamily: "Dubai",
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            duration: Duration(milliseconds: 3000),
            curve: Curves.easeOutQuint,
          ),
          const SizedBox(height: 20,),
          Center(
            child: FadeInUp(
              duration: const Duration(milliseconds: 2000),
              child: Image.asset(
                'assets/splash_image.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
