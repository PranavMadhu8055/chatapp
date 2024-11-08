import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'; // Import emoji picker package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(user: userCredential.user!)),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _signUp() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(user: userCredential.user!)),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;  
    final screenHeight = MediaQuery.of(context).size.height;  

    return Scaffold(
      backgroundColor: Color(0XFFF9F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: AlignmentDirectional(0, 0),
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Color(0XFF112D4E),
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                )),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0XFF112D4E),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    hintText: 'Enter your email',
                    // enabledBorder: OutlineInputBorder(
                    //     borderSide:
                    //         BorderSide(color: Colors.black, width: 1)),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //     color: Color(0x00000000),
                    //     width: 1,
                    //   ),
                    // ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.white),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0XFF112D4E),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    hintText: 'Enter your password',
                    // enabledBorder: OutlineInputBorder(
                    //     borderSide:
                    //         BorderSide(color: Colors.black, width: 1)),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //     color: Color(0x00000000),
                    //     width: 1,
                    //   ),
                    // ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.white),
                obscureText: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: screenWidth/3,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF112D4E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth/3,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                    
                      backgroundColor: Color(0XFF112D4E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final User user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showEmojiPicker = false;

  // Track which message is currently long-pressed
  String? _selectedMessageId;

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      await _firestore.collection('messages').add({
        'text': messageText,
        'sender': widget.user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  void _deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
    setState(() {
      _selectedMessageId = null; // Reset the selected message
    });
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFF112D4E),
        title: Text(
          'Chat room',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = messages.map((doc) {
                  final messageData = doc.data() as Map<String, dynamic>;
                  final messageText = messageData['text'];
                  final senderName = messageData['sender'];
                  bool isMe = widget.user.email == senderName;

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _selectedMessageId = isMe
                            ? doc.id
                            : null; // Select message for deletion if it's sent by me
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 4, horizontal: isMe ? 50 : 10),
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        shadowColor: Colors.black,
                        color: isMe ? Colors.blueAccent : Colors.grey[300],
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageText,
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black),
                              ),
                              Text(
                                senderName,
                                style: TextStyle(
                                    fontSize: 10.0, color: Colors.black54),
                              ),
                              if (_selectedMessageId ==
                                  doc.id) // Show delete button if this message is selected
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteMessage(
                                        doc.id); // Delete the message
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList();

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji emoji) {
                  setState(() {
                    _messageController.text += emoji.emoji;
                  });
                },
              ),
            ),
          Container(
            color: Color(0XFF3F72AF),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Color(0XFFDBE2EF),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                            hintText: 'Enter your message',
                            // enabledBorder: OutlineInputBorder(
                            //     borderSide:
                            //         BorderSide(color: Colors.black, width: 1)),
                            // focusedBorder: OutlineInputBorder(
                            //   borderSide: BorderSide(
                            //     color: Color(0x00000000),
                            //     width: 1,
                            //   ),
                            // ),
                            fillColor: Colors.white),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleEmojiPicker,
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.white,
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
