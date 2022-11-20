// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class ConnectionLost extends StatefulWidget {
  const ConnectionLost({super.key});

  @override
  _ConnectionLostState createState() => _ConnectionLostState();
}

class _ConnectionLostState extends State<ConnectionLost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
      ),
      body:  Center(
        child: Column(
          children: [
         const   Padding(
              padding:  EdgeInsets.all(8.0),
              child: Text(
                "No Internet",
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontFamily: 'cute'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Make sure that Your WIFI or Mobile Network in On",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontSize: 10, fontFamily: 'cute'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Icon(
                      Icons.refresh_sharp,
                      size: 22,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                 const   Text(
                      "Refresh",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'cute'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
