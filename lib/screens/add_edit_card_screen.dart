import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  String _suit = 'Hearts';
  String? _base64Image; // gallery-picked image stored as base64

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card?.cardName ?? '');
    final existingUrl = widget.card?.imageUrl ?? '';
    // If stored value is base64 (not a URL), restore it to gallery state
    if (existingUrl.isNotEmpty && !existingUrl.startsWith('http')) {
      _base64Image = existingUrl;
      _imageUrlController = TextEditingController(text: '');
    } else {
      _imageUrlController = TextEditingController(text: existingUrl);
    }
    _suit = widget.card?.suit ?? 'Hearts';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await File(picked.path).readAsBytes();
    setState(() {
      _base64Image = base64Encode(bytes);
      _imageUrlController.clear();
    });
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      // Gallery base64 takes priority over typed URL
      String? imageValue;
      if (_base64Image != null) {
        imageValue = _base64Image;
      } else if (_imageUrlController.text.trim().isNotEmpty) {
        imageValue = _imageUrlController.text.trim();
      }

      final card = PlayingCard(
        id: widget.card?.id,
        cardName: _nameController.text.trim(),
        suit: _suit,
        imageUrl: imageValue,
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

  Widget _buildPreview() {
    if (_base64Image != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Image.memory(
          base64Decode(_base64Image!),
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(Icons.broken_image, size: 60),
        ),
      );
    }
    if (_imageUrlController.text.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Image.network(
          _imageUrlController.text,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(Icons.broken_image, size: 60),
        ),
      );
    }
    return SizedBox.shrink();
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
                onChanged: (_) {
                  if (_base64Image != null) {
                    setState(() => _base64Image = null);
                  } else {
                    setState(() {});
                  }
                },
              ),
              SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: Icon(Icons.photo_library),
                label: Text(
                  _base64Image != null
                      ? 'Gallery image selected — tap to change'
                      : 'Pick Image from Gallery',
                ),
              ),
              _buildPreview(),
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
