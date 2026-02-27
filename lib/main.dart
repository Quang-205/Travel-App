import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const SmartNoteApp());
}

// --- Model Ghi chú ---
class Note {
  String id;
  String title;
  String content;
  DateTime dateTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
  });

  // Chuyển từ Map sang Object (JSON decode)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      dateTime: DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển từ Object sang Map (JSON encode)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Note',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
      home: const NoteListScreen(),
    );
  }
}

// --- Màn hình chính ---
class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotesFromStorage();
    _searchController.addListener(_onSearchChanged);
  }

  // Tải dữ liệu từ máy
  Future<void> _loadNotesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('notes_data');
    if (notesJson != null) {
      final List<dynamic> decodedList = jsonDecode(notesJson);
      setState(() {
        _notes = decodedList.map((item) => Note.fromJson(item)).toList();
        _notes.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Mới nhất lên đầu
        _filteredNotes = _notes;
      });
    }
  }

  // Lưu dữ liệu xuống máy
  Future<void> _saveNotesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await prefs.setString('notes_data', encodedData);
  }

  // Tìm kiếm real-time
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes
          .where((note) => note.title.toLowerCase().contains(query))
          .toList();
    });
  }

  // Xóa ghi chú với xác nhận
  Future<void> _deleteNote(Note note) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
        _onSearchChanged();
      });
      await _saveNotesToStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Note - Vũ Văn Quảng - 2351160543'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tiêu đề...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Danh sách ghi chú (Masonry Grid)
          Expanded(
            child: _notes.isEmpty
                ? _buildEmptyState()
                : MasonryGridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return _NoteCard(
                        note: note,
                        onDelete: () => _deleteNote(note),
                        onTap: () => _navigateToEdit(note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(null),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.2,
            child: Icon(Icons.note_alt, size: 100, color: Colors.blueAccent[100]),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có ghi chú nào, hãy tạo mới nhé!',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(Note? note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
    );
    _loadNotesFromStorage(); // Refresh khi quay lại (Auto-save đã hoàn tất)
  }
}

// --- Widget Thẻ ghi chú ---
class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // Quản lý thông qua hàm onDelete với Dialog xác nhận
      },
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(note.dateTime),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Màn hình Soạn thảo ---
class EditNoteScreen extends StatefulWidget {
  final Note? note;
  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _currentNoteId; // Theo dõi ID ghi chú trong phiên làm việc này

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _currentNoteId = widget.note?.id; // Nếu đang sửa ghi chú cũ, gán ID cũ
  }

  // Tính năng Auto-save
  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Không lưu nếu hoàn toàn trống
    if (title.isEmpty && content.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('notes_data');
    List<Note> notes = [];

    if (notesJson != null) {
      final List<dynamic> decodedList = jsonDecode(notesJson);
      notes = decodedList.map((item) => Note.fromJson(item)).toList();
    }

    if (_currentNoteId == null) {
      // TRƯỜNG HỢP TẠO MỚI (Lần đầu tiên lưu trong phiên này)
      _currentNoteId = DateTime.now().millisecondsSinceEpoch.toString();
      notes.add(Note(
        id: _currentNoteId!,
        title: title.isEmpty ? "Không có tiêu đề" : title,
        content: content,
        dateTime: DateTime.now(),
      ));
    } else {
      // TRƯỜNG HỢP CẬP NHẬT (Ghi chú cũ hoặc ghi chú mới đã được lưu trước đó 1 giây)
      final index = notes.indexWhere((n) => n.id == _currentNoteId);
      if (index != -1) {
        notes[index].title = title.isEmpty ? "Không có tiêu đề" : title;
        notes[index].content = content;
        notes[index].dateTime = DateTime.now();
      } else {
        // Phòng trường hợp ID đã có nhưng không tìm thấy trong list (vd: vừa bị xóa)
        notes.add(Note(
          id: _currentNoteId!,
          title: title.isEmpty ? "Không có tiêu đề" : title,
          content: content,
          dateTime: DateTime.now(),
        ));
      }
    }

    await prefs.setString('notes_data', jsonEncode(notes.map((n) => n.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        // Chỉ lưu khi màn hình thực sự đóng
        if (didPop) await _autoSave();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _autoSave();
                if (mounted) Navigator.pop(context);
              },
              child: const Text(
                'Xong',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  border: InputBorder.none,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: 'Bắt đầu viết nội dung...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
