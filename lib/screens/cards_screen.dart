import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/playing_card.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  CardsScreen({required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();
  List<PlayingCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _cardRepo.getCardsByFolderId(widget.folder.id!);
    setState(() {
      _cards = cards;
    });
  }

  Future<void> _deleteCard(PlayingCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Delete Card?'),
        content: Text(
          'Are you sure you want to delete "${card.cardName} of ${card.suit}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cardRepo.deleteCard(card.id!);
      _loadCards();
    }
  }

  Widget _buildCardImage(PlayingCard card) {
    if (card.imageUrl == null || card.imageUrl!.isEmpty) {
      return Icon(Icons.style, size: 48, color: Colors.grey);
    }
    // Base64-encoded gallery image
    if (!card.imageUrl!.startsWith('http')) {
      try {
        return Image.memory(
          base64Decode(card.imageUrl!),
          width: 60,
          height: 84,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
        );
      } catch (_) {
        return Icon(Icons.broken_image, size: 48, color: Colors.grey);
      }
    }
    // Network URL
    return Image.network(
      card.imageUrl!,
      width: 60,
      height: 84,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          Icon(Icons.broken_image, size: 48, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.folderName),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditCardScreen(folder: widget.folder),
            ),
          );
          _loadCards();
        },
      ),
      body: _cards.isEmpty
          ? Center(child: Text('No cards in this folder.'))
          : ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return ListTile(
                  leading: _buildCardImage(card),
                  title: Text(card.cardName),
                  subtitle: Text(card.suit),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditCardScreen(
                                folder: widget.folder,
                                card: card,
                              ),
                            ),
                          );
                          _loadCards();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCard(card),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
