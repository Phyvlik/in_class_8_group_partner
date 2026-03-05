import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/playing_card.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final Folder folder;
  final PlayingCard? card;

  AddEditCardScreen({required this.folder, this.card});

  @override
  _AddEditCardScreenState createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepo = CardRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  String _suit = 'Hearts';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card?.cardName ?? '');
    _imageUrlController = TextEditingController(text: widget.card?.imageUrl ?? '');
    _suit = widget.card?.suit ?? 'Hearts';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final card = PlayingCard(
        id: widget.card?.id,
        cardName: _nameController.text.trim(),
        suit: _suit,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        folderId: widget.folder.id!,
      );

      if (widget.card == null) {
        await _cardRepo.insertCard(card);
      } else {
        await _cardRepo.updateCard(card);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Card Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter card name' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _suit,
                items: ['Hearts', 'Diamonds', 'Clubs', 'Spades']
                    .map((suit) => DropdownMenuItem(value: suit, child: Text(suit)))
                    .toList(),
                onChanged: (value) => setState(() => _suit = value!),
                decoration: InputDecoration(labelText: 'Suit'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  hintText: 'https://example.com/card.png',
                ),
              ),
              SizedBox(height: 8),
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Image.network(
                    _imageUrlController.text,
                    height: 120,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.broken_image, size: 60),
                  ),
                ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveCard,
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
