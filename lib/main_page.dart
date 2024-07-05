import 'package:dart_amqp/dart_amqp.dart';
import 'package:desktop_friendly_app/screens/statistics_screen.dart';
import 'package:desktop_friendly_app/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // late ConnectionSettings settings;
  // late Client client;
  // late Channel channel;
  // late Queue queue;

  @override
  void initState() {
    super.initState();
    // connectToRabbitMQ();
  }

  // void connectToRabbitMQ() async {
  //   settings = ConnectionSettings(
  //     host: 'localhost',
  //     port: 5672,
  //     virtualHost: '/',
  //     authProvider: const PlainAuthenticator('myuser', 'mypass'),
  //   );

  //   client = Client(settings: settings);
  //   try {
  //     channel = await client.channel();
  //     queue = await channel.queue('userRegisterQueue');

  //     var consumer = await queue.consume();


  //     consumer.listen((AmqpMessage message) {

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.green,
  //           content: Text(message.payloadAsString),
  //           duration: Duration(seconds: 3),
  //            action: SnackBarAction(
  //             label: 'DISMISS',
  //             textColor: Colors.white,
  //             onPressed: () {
  //               // Code to execute when the action button is pressed
  //             },
  //   ),
  //         ),
  //       );

  //     });
  //   } catch (e) {
  //     print("An error occurred: $e");
  //   }
  // }

  @override
  void dispose() {
    // client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  "Friendly App - Admin Panel",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: StatisticsScreen(),
        ),
      ),
    );
  }
}
