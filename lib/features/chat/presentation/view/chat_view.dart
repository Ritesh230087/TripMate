import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/features/chat/data/model/chat_message_model.dart';
import '../../../../app/constant/api_endpoints.dart';
import '../../../../core/network/socket_service.dart';

class ChatView extends StatefulWidget {
  final String rideId;
  final String currentUserId;
  final String otherUserName;
  final String? otherUserImage; 

  const ChatView({
    super.key,
    required this.rideId,
    required this.currentUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final SocketService _socket = SocketService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _socket.connect();
    _socket.joinRideRoom(widget.rideId);

    // Load history
    _socket.socket.on('chat_history', (data) {
      if (mounted) {
        final List history = data as List;
        setState(() {
          _messages.clear();
          _messages.addAll(history.map((m) => ChatMessage.fromJson(m)).toList());
        });
        _scrollToBottom();
      }
    });

    // Receive message
    _socket.socket.off('receive_message'); 
    _socket.socket.on('receive_message', (data) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: data['message'] ?? '', 
            senderId: data['senderId'] ?? '', 
            timestamp: DateTime.now()
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _socket.socket.off('receive_message');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Construct safe image URL
    String? imageUrl;
    if (widget.otherUserImage != null && widget.otherUserImage!.isNotEmpty) {
      imageUrl = "${ApiEndpoints.imageUrl}${widget.otherUserImage!.replaceAll(r'\', '/')}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFEEE4DB),
                backgroundImage: (widget.otherUserImage != null && widget.otherUserImage!.isNotEmpty)
      ? NetworkImage("${ApiEndpoints.imageUrl}${widget.otherUserImage!.replaceAll(r'\', '/')}")
      : null,
  child: (widget.otherUserImage == null || widget.otherUserImage!.isEmpty)
      ? const Icon(Icons.person, color: Colors.brown) // Fallback if no image
      : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Chat", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              Text(widget.otherUserName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ])),
            GestureDetector(onTap: () => Navigator.pop(context), child: Text("Close", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFFCF9F4),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final msg = _messages[i];
                  bool isMe = msg.senderId == widget.currentUserId;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFE8D5C4) : const Color(0xFFEEE4DB), 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(msg.text, style: GoogleFonts.inter(color: const Color(0xFF4A342E), fontSize: 15)),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildInputArea()
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: Row(children: [
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Type...", border: InputBorder.none))),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFF8B4513)),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                _socket.sendMessage(widget.rideId, widget.currentUserId, _controller.text.trim(), "Me");
                _controller.clear();
              }
            },
          )
        ]),
      ),
    );
  }
}