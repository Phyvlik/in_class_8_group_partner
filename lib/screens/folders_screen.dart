import 'package:flutter/material.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';
import '../models/folder.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepo = FolderRepository();
  final CardRepository _cardRepo = CardRepository();

  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepo.getAllFolders();
    final Map<int, int> counts = {};

    for (var folder in folders) {
      counts[folder.id!] =
          await _cardRepo.getCardCountByFolder(folder.id!);
    }

    setState(() {
      _folders = folders;
      _cardCounts = counts;
    });
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Delete Folder?"),
        content: Text(
          "Deleting '${folder.folderName}' will also delete "
          "${_cardCounts[folder.id!] ?? 0} cards inside it.\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _folderRepo.deleteFolder(folder.id!);
      _loadFolders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Folders")),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];

          return Card(
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardsScreen(folder: folder),
                  ),
                );
                _loadFolders();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    folder.folderName,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      "${_cardCounts[folder.id!] ?? 0} cards"),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFolder(folder),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}