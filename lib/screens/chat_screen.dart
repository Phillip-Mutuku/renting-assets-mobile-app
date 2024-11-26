import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart' as record_lib;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late record_lib.AudioRecorder recorder;
  final audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordingPath;
  final ScrollController _scrollController = ScrollController();
  String? _currentlyPlayingPath;
  bool _isPlaying = false;

  // Sample users data
  final List<Map<String, dynamic>> users = [
    {
      'id': '1',
      'name': 'John Doe',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'lastSeen': 'Online',
      'unreadCount': 3,
      'lastMessage': 'Hey, when can we meet?',
      'lastMessageTime': '3:30 PM',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'lastSeen': '2 min ago',
      'unreadCount': 1,
      'lastMessage': 'The meeting is scheduled for tomorrow',
      'lastMessageTime': '2:15 PM',
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'lastSeen': 'Last seen yesterday',
      'unreadCount': 0,
      'lastMessage': 'Thanks for your help!',
      'lastMessageTime': 'Yesterday',
    },
    {
      'id': '4',
      'name': 'Sarah Wilson',
      'avatar': 'https://i.pravatar.cc/150?img=4',
      'lastSeen': 'Online',
      'unreadCount': 2,
      'lastMessage': 'Please check the documents',
      'lastMessageTime': '4:45 PM',
    },
    {
      'id': '5',
      'name': 'David Brown',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'lastSeen': '5 min ago',
      'unreadCount': 0,
      'lastMessage': 'See you at the event!',
      'lastMessageTime': '1:30 PM',
    },
  ];

  // Messages data structure
  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> filteredUsers = [];
  Map<String, dynamic>? selectedUser;

  @override
  void initState() {
    super.initState();
    recorder = record_lib.AudioRecorder();
    filteredUsers = List.from(users);
    _initializeRecorder();
    _initializeAudioPlayer();
  }

  Future<void> _initializeRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw 'Microphone permission not granted';
      }
    } catch (e) {
      _showErrorSnackBar('Error initializing recorder');
    }
  }

  void _initializeAudioPlayer() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentlyPlayingPath = null;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    recorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) =>
          user['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        _addMessage(
          type: 'image',
          content: image.path,
          isSent: true,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      if (result != null) {
        _addMessage(
          type: 'file',
          content: result.files.single.path!,
          fileName: result.files.single.name,
          isSent: true,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/audio_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await recorder.start(
          const record_lib.RecordConfig(
            encoder: record_lib.AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        setState(() {
          _isRecording = true;
          _recordingPath = filePath;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error starting recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await recorder.stop();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        _addMessage(
          type: 'audio',
          content: path,
          isSent: true,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error stopping recording');
    }
  }




  Future<void> _playAudio(String path) async {
    try {
      if (_currentlyPlayingPath == path && _isPlaying) {
        await audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await audioPlayer.stop();
        await audioPlayer.play(DeviceFileSource(path));
        setState(() {
          _currentlyPlayingPath = path;
          _isPlaying = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error playing audio');
    }
  }

  void _addMessage({
    required String type,
    required String content,
    required bool isSent,
    String? fileName,
  }) {
    setState(() {
      _messages.add({
        'type': type,
        'content': content,
        'timestamp': DateTime.now(),
        'isSent': isSent,
        'fileName': fileName,
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: selectedUser == null ? _buildUserList() : _buildChatView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A1931),
      elevation: 0,
      title: selectedUser == null
          ? const Text(
        'Messages',
        style: TextStyle(color: Colors.white),
      )
          : Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(selectedUser!['avatar']),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedUser!['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  selectedUser!['lastSeen'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      leading: selectedUser != null
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            selectedUser = null;
            _messages.clear();
          });
        },
      )
          : null,
      actions: selectedUser != null
          ? [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {
            // Implement video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            // Implement voice call
          },
        ),
      ]
          : null,
    );
  }
  Widget _buildUserList() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        // User List
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(user['avatar']),
                      ),
                      if (user['lastSeen'] == 'Online')
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    user['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user['lastMessageTime'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: user['unreadCount'] > 0
                      ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1931),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user['unreadCount'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : null,
                  onTap: () {
                    setState(() {
                      selectedUser = user;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              image: DecorationImage(
                image: const NetworkImage(
                  'https://i.pinimg.com/originals/97/c0/07/97c00759d90d786d9b6096d274ad3e07.png',
                ),
                opacity: 0.1,
                repeat: ImageRepeat.repeat,
              ),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSent = message['isSent'];
    final align = isSent ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor = isSent ? const Color(0xFF0A1931) : Colors.white;
    final textColor = isSent ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isSent ? const Radius.circular(0) : null,
                bottomLeft: !isSent ? const Radius.circular(0) : null,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageContent(message, textColor),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message['timestamp']),
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message, Color textColor) {
    switch (message['type']) {
      case 'text':
        return Text(
          message['content'],
          style: TextStyle(color: textColor),
        );
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(message['content']),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      case 'file':
        return InkWell(
          onTap: () {
            // Implement file opening
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.attach_file, color: textColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message['fileName']!,
                  style: TextStyle(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      case 'audio':
        bool isPlaying = _currentlyPlayingPath == message['content'] && _isPlaying;
        return InkWell(
          onTap: () => _playAudio(message['content']),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Message',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAttachmentOptions,
              color: const Color(0xFF0A1931),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.red : const Color(0xFF0A1931),
                    ),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
                    _addMessage(
                      type: 'text',
                      content: text,
                      isSent: true,
                    );
                    _messageController.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: const Color(0xFF0A1931),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  _addMessage(
                    type: 'text',
                    content: _messageController.text,
                    isSent: true,
                  );
                  _messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0A1931),
                child: Icon(Icons.image, color: Colors.white),
              ),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0A1931),
                child: Icon(Icons.attach_file, color: Colors.white),
              ),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
  }