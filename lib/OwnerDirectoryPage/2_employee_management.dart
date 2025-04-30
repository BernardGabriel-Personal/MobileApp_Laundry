import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:intl/intl.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  Set<String> _loadingIds = {};

  // Random Password Generator
  String generatePassword({required String employeeId}) {
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final Random random = Random.secure();
    String randomUppercase = List.generate(
      5,
      (index) => uppercaseChars[random.nextInt(uppercaseChars.length)],
    ).join();

    return '$employeeId$randomUppercase';
  }

  // Email Sending Function
  Future<void> sendEmail(
      String recipientEmail, String employeeId, String password) async {
    String username = 'bernardgabriel151@gmail.com';
    String passwordApp = 'gafumrtlknkdahww'; // gafu mrtl knkd ahww

    final smtpServer = gmail(username, passwordApp);

    final message = Message()
      ..from = Address(username, 'Five-Stars Laundry')
      ..recipients.add(recipientEmail)
      ..subject = 'Five-Stars Laundry Employee Account Approval'
      ..html = '''
      <div style="background-color: #f4f4f4; padding: 20px; font-family: Arial, sans-serif;">
        <div style="text-align: center;">
        <img src="https://media-hosting.imagekit.io/9b51a43beffc4f23/FiveStarsLaundromat.png?Expires=1840554596&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=cOlx1ZmmHBALGg0GLJsqmEYLxEzqIh2tZeOg6EUXGsqsCvdCeW6k4Nx0S7ggmRX19BDuODhziQ89kUozzc5~Pbzd8iEVC3jn7~a6RdE0OY-sA2A9rkhd4hERhAbG9yNsU18zYcCYTugVjsEsUR7Uu7U~SKWfOKiUBcwIbBB-td0vasLeFYNSWeZrrX-28UMmAnaOQOyin3DzI8Et0SnwFkh3H7GBpyEZM42Z0Miadn0vG22LwZJekCVD1wV~XTcU6pAKtYW8WOADo86TURiOp94yy67fijpzaqFiU0YfnO-dnQn08qNoaz3Kswu8yq4xp6elVwUzf25I8uv5CDaApg__" alt="Five-Stars Laundry Logo" width="200">
        </div>
        <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
          <p style="font-size: 18px; font-weight: bold;">Dear Fresh & Pressed Team Member,</p>
          <p>Welcome to the <strong>Five-Stars Laundry</strong> family! Your employee account has been officially approved.</p>
          <p><strong>Here are your login details:</strong></p>
          <ul>
            <li><strong>Employee ID:</strong> $employeeId</li>
            <li><strong>Temporary Password:</strong> $password</li>
          </ul>
          <p>Please use these credentials to log in and be sure to <strong>update your password</strong> for security.</p>
          <p style="text-align: left;">Best regards,<br><strong>MYThic Team</strong></p>
        </div>
      </div>
      ''';

    try {
      await send(message, smtpServer);
      print('Email sent successfully to $recipientEmail');
    } catch (e) {
      print('Failed to send email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9D4),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Center(
                  child: Text(
                    'Pending Employee Approvals',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B5D74),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 3,
                    radius: const Radius.circular(10),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('admin')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No admins found.'));
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var admin = snapshot.data!.docs[index];
                            String adminId = admin.id;

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF04D26F),
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  admin['fullName'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF3B5D74),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Email: ${admin['email'] ?? 'N/A'}\n'
                                    'Contact: ${admin['contact'] ?? 'N/A'}\n'
                                    'Employee ID: ${admin['employeeId'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                trailing: _loadingIds.contains(adminId)
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF04D26F),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _loadingIds.contains(adminId)
                                            ? null
                                            : () async {
                                                setState(() {
                                                  _loadingIds.add(adminId);
                                                });

                                                try {
                                                  String employeeId =
                                                      admin['employeeId']
                                                          .toString();
                                                  String password =
                                                      generatePassword(
                                                          employeeId:
                                                              employeeId);

                                                  await sendEmail(
                                                      admin['email'] ?? '',
                                                      employeeId,
                                                      password);

                                                  var createdAt =
                                                      admin['createdAt'];
                                                  String formattedDate = createdAt
                                                          is Timestamp
                                                      ? DateFormat(
                                                              'yyyy-MM-dd HH:mm:ss')
                                                          .format(createdAt
                                                              .toDate())
                                                      : createdAt.toString();

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'approved_admin')
                                                      .add({
                                                    'branch':
                                                        admin['branch'] ?? '',
                                                    'contact':
                                                        admin['contact'] ?? '',
                                                    'createdAt': formattedDate,
                                                    'email':
                                                        admin['email'] ?? '',
                                                    'employeeId': employeeId,
                                                    'fullName':
                                                        admin['fullName'] ?? '',
                                                    'password': password,
                                                  });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('admin')
                                                      .doc(adminId)
                                                      .delete();

                                                  await ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Employee approved and email sent!'),
                                                          backgroundColor:
                                                              Colors.green,
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ),
                                                      )
                                                      .closed;

                                                  if (!mounted) return;
                                                  setState(() {
                                                    _loadingIds.remove(adminId);
                                                  });
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          Text('Error: $e'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );

                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 300));

                                                  if (!mounted) return;
                                                  setState(() {
                                                    _loadingIds.remove(adminId);
                                                  });
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF04D26F),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Text(
                                          'Approve',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.grey[600],
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
