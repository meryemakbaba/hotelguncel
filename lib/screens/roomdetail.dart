/*
import 'dart:convert'; // Fotoğrafları decode etmek için
import 'package:flutter/material.dart';
import 'package:serenadepalace/widgets/custom_scaffold.dart'; // Make sure CustomScaffold is imported

class SecondPage extends StatelessWidget {
  final dynamic room;

  const SecondPage({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> imagesBase64 = room['images'];
    String type = room['type'];
    double price = room['price'];

    return CustomScaffold(
      child: Column(
        children: [
          // Image carousel with navigation
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  // Room title and price
                  Text(
                    'Room Type: $type',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Price: ₺ ${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20),

                  // Image gallery with buttons to navigate through images
                  Expanded(
                    child: Stack(
                      children: [
                        // Left button for navigation
                        Positioned(
                          left: 10,
                          top: 50,
                          bottom: 50,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, size: 30),
                            onPressed: () {
                              // TODO: Implement backward navigation for images
                            },
                          ),
                        ),
                        // Right button for navigation
                        Positioned(
                          right: 10,
                          top: 50,
                          bottom: 50,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward, size: 30),
                            onPressed: () {
                              // TODO: Implement forward navigation for images
                            },
                          ),
                        ),

                        // Image display area
                        PageView.builder(
                          itemCount: imagesBase64.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  // Open the image in full screen
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: Image.memory(
                                        base64Decode(imagesBase64[index]),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(imagesBase64[index]),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Room details section
                  Text('Room details for $type will be displayed here.', style: TextStyle(fontSize: 14.0)),

                  // Price and booking button
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺ ${price.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to reservation page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 143, 115, 94),
                          ),
                          child: const Text(
                            'Reserve Now',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/


import 'dart:convert'; // Fotoğrafları decode etmek için
import 'package:flutter/material.dart';
import 'package:serenadepalace/screens/rezervation.dart';
import 'package:serenadepalace/widgets/custom_scaffold.dart'; // CustomScaffold import

class SecondPage extends StatefulWidget {
  final dynamic room;

  const SecondPage({Key? key, required this.room}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late List<dynamic> imagesBase64; // Image list from Firebase
  late int currentIndex; // To track the current image index

  @override
  void initState() {
    super.initState();
    imagesBase64 = widget.room['images']; // Get the images from Firebase
    currentIndex = 0; // Start at the first image
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.room['type'];
    double price = (widget.room['price'] as num).toDouble();
    return CustomScaffold(
      child: Column(
        children: [
          // White container with heading and room details
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  // Room title and price
                  Text(
                    'Room Type: $type',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Price: £ ${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20),

                  // Image gallery with navigation buttons (first state only)
                  Expanded(
                    child: Stack(
                      children: [
                        // Sol ok düğmesi
                        

                        // Resim gösterimi
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Resmi büyütmek için tam ekran görüntü
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Stack(
                                    children: [
                                      Image.memory(
                                        base64Decode(imagesBase64[currentIndex]),
                                        fit: BoxFit.contain,
                                      ),
                                      // Çıkış düğmesi
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, size: 30, color: Colors.black),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(imagesBase64[currentIndex]),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentIndex > 0)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  currentIndex -= 1; // Bir önceki resme geç
                                });
                              },
                            ),
                          ),

                        // Sağ ok düğmesi
                        const SizedBox(height: 20),
                        if (currentIndex < imagesBase64.length - 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward, size: 30, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  currentIndex += 1; // Bir sonraki resme geç
                                });
                              },
                            ),
                          ),
                  // Room details section (optional, can be customized)
                  Text('Room details for $type will be displayed here.', style: const TextStyle(fontSize: 14.0)),

                  // Price and booking button
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '£ ${price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        ElevatedButton(
                          onPressed: () {
                           Navigator.push(
  context,
  MaterialPageRoute(
    builder: (e) => RezervationScreen(room: widget.room),
  ),
);

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 143, 115, 94),
                          ),
                          child: const Text(
                            'Reserve Now',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


