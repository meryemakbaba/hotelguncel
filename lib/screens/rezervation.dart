

/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serenadepalace/widgets/custom_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class RezervationScreen extends StatefulWidget {
  final dynamic room;

  const RezervationScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RezervationScreen> createState() => _RezervationScreenState();
}

class _RezervationScreenState extends State<RezervationScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool isLoading = false;
  String? userName;
  String? userEmail;
  late User? currentUser;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Person').doc(currentUser!.uid).get();
      setState(() {
        userName = userDoc['userName'];
        userEmail = userDoc['email'];
      });
    }
  }

  Future<void> _reserveRoom() async {
    if (selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select both start and end dates.')));

      return;
    }

    if (selectedEndDate!.isBefore(selectedStartDate!)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter valid dates: End date must be after Start date.')));
      return;
    }

    if (selectedStartDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a valid start date: It cannot be in the past.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    String roomId = widget.room.id;
    double pricePerNight = (widget.room['price'] as num).toDouble();
    int nights = selectedEndDate!.difference(selectedStartDate!).inDays ;
    double totalCost = pricePerNight * nights;

    try {
      QuerySnapshot reservations = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(roomId)
          .collection('Guests')
          .where('endDate', isGreaterThanOrEqualTo: selectedStartDate)
          .get();

      if (reservations.docs.isNotEmpty) {
        DateTime nextAvailableDate = reservations.docs
            .map((doc) => (doc['endDate'] as Timestamp).toDate())
            .reduce((a, b) => a.isAfter(b) ? a : b);
        nextAvailableDate = nextAvailableDate.add(const Duration(days: 1));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Room is not available. Next available date is ${DateFormat('yyyy-MM-dd').format(nextAvailableDate)}.'),
        ));
        setState(() {
          isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(roomId)
          .collection('Guests')
          .add({
        'userName': userName,
        'email': userEmail,
        'startDate': selectedStartDate,
        'endDate': selectedEndDate,
      });

      await FirebaseFirestore.instance
          .collection('Person')
          .doc(currentUser!.uid)
          .collection('Room')
          .add({
        'roomNumber': widget.room['roomNumber'],
        'startDate': selectedStartDate,
        'endDate': selectedEndDate,
        'cost': totalCost,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation completed successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return CustomScaffold(
    child: Column(
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        Expanded( // This ensures the content takes all available space
          child: SingleChildScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Select the dates',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 143, 115, 94),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: DateTime.now(),
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedStartDate, day) || isSameDay(selectedEndDate, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        if (selectedStartDate == null || selectedEndDate != null && selectedDay.isBefore(selectedStartDate!)) {
                          selectedStartDate = selectedDay;
                          selectedEndDate = null;
                        } else if (selectedStartDate != null && isSameDay(selectedStartDate!, selectedDay)) {
                          selectedStartDate = null;  // Deselect start date
                        } else if (selectedEndDate != null && isSameDay(selectedEndDate!, selectedDay)) {
                          selectedEndDate = null;  // Deselect end date
                        } else if (selectedStartDate != null && selectedDay.isAfter(selectedStartDate!)) {
                          selectedEndDate = selectedDay;
                        }
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color.fromARGB(255, 143, 115, 94),
                        shape: BoxShape.rectangle,
                      ),
                      disabledDecoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    availableGestures: AvailableGestures.none,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (selectedStartDate != null && selectedEndDate != null)
                    Column(
                      children: [
                        Text(
                          'Enter Day: ${DateFormat('yyyy-MM-dd').format(selectedStartDate!)}',
                          style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 143, 115, 94),),
                        ),
                        Text(
                          'Exit Day: ${DateFormat('yyyy-MM-dd').format(selectedEndDate!)}',
                          style: const TextStyle(fontSize:14, color: Color.fromARGB(255, 143, 115, 94),),
                        ),
                        Text(
                          'Cost: \$${(widget.room['price'] as num).toDouble() * selectedEndDate!.difference(selectedStartDate!).inDays} ',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 143, 115, 94),),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: isLoading ? null : _reserveRoom,
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 143, 115, 94),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Reserve Now', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
 }

}
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serenadepalace/widgets/custom_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:serenadepalace/home2.dart'; 

class RezervationScreen extends StatefulWidget {
  final dynamic room;

  const RezervationScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RezervationScreen> createState() => _RezervationScreenState();
}

class _RezervationScreenState extends State<RezervationScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool isLoading = false;
  String? userName;
  String? userEmail;
  late User? currentUser;
  DateTime focusedDay = DateTime.now(); // Initialize focusedDay with current date
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Person').doc(currentUser!.uid).get();
      setState(() {
        userName = userDoc['userName'];
        userEmail = userDoc['email'];
      });
    }
  }

Future<void> _reserveRoom() async {
  if (selectedStartDate == null || selectedEndDate == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Please select both start and end dates.')));
    return;
  }

  if (selectedEndDate!.isBefore(selectedStartDate!)) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Please enter valid dates: End date must be after Start date.')));
    return;
  }

  if (selectedStartDate!.isBefore(DateTime.now())) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Please enter a valid start date: It cannot be in the past.')));
    return;
  }

  setState(() {
    isLoading = true;
  });

  String roomId = widget.room.id;
  double pricePerNight = (widget.room['price'] as num).toDouble();
  int nights = selectedEndDate!.difference(selectedStartDate!).inDays;
  double totalCost = pricePerNight * nights;

  try {
    // Get all reservations for the specific room from the Guests collection
    QuerySnapshot reservations = await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomId)
        .collection('Guests')
        .get();

    // Loop through all the reservations and check if the selected range overlaps with any reservation
    for (var reservation in reservations.docs) {
      DateTime reservationStartDate = (reservation['startDate'] as Timestamp).toDate();
      DateTime reservationEndDate = (reservation['endDate'] as Timestamp).toDate();

      // Check if the selected date range overlaps with any existing reservation
      if ((selectedStartDate!.isBefore(reservationEndDate) || isSameDay(selectedStartDate!, reservationEndDate)) &&
          (selectedEndDate!.isAfter(reservationStartDate) || isSameDay(selectedEndDate!, reservationStartDate))) {
        // If there's an overlap, show a message and prevent the reservation
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Room is not available from ${DateFormat('yyyy-MM-dd').format(selectedStartDate!)} to ${DateFormat('yyyy-MM-dd').format(selectedEndDate!)}.'),
        ));
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    // If no conflicts, proceed with the reservation
    await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomId)
        .collection('Guests')
        .add({
      'userName': userName,
      'email': userEmail,
      'startDate': selectedStartDate,
      'endDate': selectedEndDate,
    });

    await FirebaseFirestore.instance
        .collection('Person')
        .doc(currentUser!.uid)
        .collection('Room')
        .add({
      'roomNumber': widget.room['roomNumber'],
      'startDate': selectedStartDate,
      'endDate': selectedEndDate,
      'cost': totalCost,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation completed successfully.')));

    // Redirect to Homepage2 after reservation
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage2()));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}





  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          Expanded( // This ensures the content takes all available space
            child: SingleChildScrollView(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Select the dates',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 143, 115, 94),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: focusedDay, // Maintain the focused day here
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedStartDate, day) || isSameDay(selectedEndDate, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          this.focusedDay = focusedDay; // Update focused day when selecting a date
                          if (selectedStartDate == null || selectedEndDate != null && selectedDay.isBefore(selectedStartDate!)) {
                            selectedStartDate = selectedDay;
                            selectedEndDate = null;
                          } else if (selectedStartDate != null && isSameDay(selectedStartDate!, selectedDay)) {
                            selectedStartDate = null;  // Deselect start date
                          } else if (selectedEndDate != null && isSameDay(selectedEndDate!, selectedDay)) {
                            selectedEndDate = null;  // Deselect end date
                          } else if (selectedStartDate != null && selectedDay.isAfter(selectedStartDate!)) {
                            selectedEndDate = selectedDay;
                          }
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color.fromARGB(255, 143, 115, 94),
                          shape: BoxShape.rectangle,
                        ),
                        disabledDecoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      availableGestures: AvailableGestures.none,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (selectedStartDate != null && selectedEndDate != null)
                      Column(
                        children: [
                          Text(
                            'Enter Day: ${DateFormat('yyyy-MM-dd').format(selectedStartDate!)}',
                            style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 143, 115, 94)),
                          ),
                          Text(
                            'Exit Day: ${DateFormat('yyyy-MM-dd').format(selectedEndDate!)}',
                            style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 143, 115, 94)),
                          ),
                          Text(
                            'Cost: \$${(widget.room['price'] as num).toDouble() * selectedEndDate!.difference(selectedStartDate!).inDays} ',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 143, 115, 94)),
                          ),
                        ],
                      ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: isLoading ? null : _reserveRoom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 143, 115, 94),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Reserve Now', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
