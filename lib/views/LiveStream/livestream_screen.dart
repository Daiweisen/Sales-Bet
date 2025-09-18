// lib/views/LiveStream/livestream_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/models/chat_model.dart';
import 'package:video_player/video_player.dart';


class LiveStreamScreen extends StatefulWidget {
  final String streamUrl;
  final String eventTitle;
  // The eventId is crucial for the chat system to link messages to a specific event.
  final String eventId;

  const LiveStreamScreen({
    Key? key,
    required this.streamUrl,
    required this.eventTitle,
    required this.eventId,
  }) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  // Firestore and Auth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // New: Controller for the text input field
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });
  }

  // New: Method to send a message to Firestore
  Future<void> _sendMessage() async {
    final user = _auth.currentUser;
    final text = _textController.text.trim();

    if (text.isNotEmpty && user != null) {
      final messageRef = _firestore.collection('chats').doc(widget.eventId).collection('messages').doc();

      final newMessage = ChatMessage(
        id: messageRef.id,
        eventId: widget.eventId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userAvatar: user.photoURL,
        message: text,
        timestamp: DateTime.now(),
      );

      await messageRef.set(newMessage.toMap());

      _textController.clear();
      // Scroll to the bottom to show the new message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventTitle),
        backgroundColor: Colors.transparent,
      ),
      body: _isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Chat',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // StreamBuilder to listen for new messages
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('chats')
                                .doc(widget.eventId)
                                .collection('messages')
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No messages yet. Be the first to chat!',
                                    style: TextStyle(color: AppTheme.mutedText),
                                  ),
                                );
                              }

                              final messages = snapshot.data!.docs
                                  .map((doc) => ChatMessage.fromMap(doc.data() as Map<String, dynamic>))
                                  .toList();

                              return ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final isCurrentUser = message.userId == _auth.currentUser?.uid;
                                  return Align(
                                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser ? AppTheme.primaryColor : AppTheme.darkCard,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isCurrentUser ? 'You' : message.userName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(message.message),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Chat input field
                        TextFormField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Say something...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _sendMessage,
                            ),
                          ),
                          onFieldSubmitted: (value) => _sendMessage(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}