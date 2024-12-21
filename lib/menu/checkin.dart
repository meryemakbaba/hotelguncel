import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:serenadepalace/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({Key? key}) : super(key: key);

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  String? userName;
  String? roomNumber;
  DateTime? startDate;
  DateTime? endDate;
  double? cost;

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  // Veritabanından kullanıcının odasına ait bilgileri alıyoruz
  Future<void> _loadReservationData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Kullanıcının oda verilerini Person koleksiyonundan alıyoruz
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Person')
            .doc(currentUser.uid)
            .collection('Room')
            .doc(currentUser.uid)  // Kullanıcının ID'si ile odasına erişiyoruz
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['userName'];
            roomNumber = userDoc['roomNumber'];
            startDate = (userDoc['startDate'] as Timestamp).toDate();
            endDate = (userDoc['endDate'] as Timestamp).toDate();
            cost = (userDoc['cost'] as num).toDouble();
          });
        } else {
          // Eğer döküman yoksa, kullanıcıya bir hata mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No reservation found')));
        }
      } catch (e) {
        print('Error fetching reservation data: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching reservation data')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userName != null && roomNumber != null) ...[
                      Text(
                        'User: $userName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Room Number: $roomNumber',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      if (startDate != null && endDate != null) ...[
                        Text(
                          'Check-in Date: ${DateFormat('yyyy-MM-dd').format(startDate!)} at 12:00 PM',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Check-out Date: ${DateFormat('yyyy-MM-dd').format(endDate!)} at 12:00 PM',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (cost != null) ...[
                        Text(
                          'Total Cost: \$${cost!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 143, 115, 94),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 40),
                    // Ödeme bölümü eklenebilir burada.
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
