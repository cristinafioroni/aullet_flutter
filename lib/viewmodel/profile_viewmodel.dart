import 'dart:io';

import 'package:flutter/material.dart';

import '../repositories/profile_repository.dart';
import '../models/profile.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  final _repo = ProfileRepository();
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // carica il profilo dell'utente corrente
  Future<void> loadProfile() async {
    _setLoading(true);
    _error = null;
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      _profile = await _repo.fetchProfile(user.id);

      // se non esiste segnala che il profilo non è stato trovato
      if (_profile == null) {
        _error = 'Profilo non trovato';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // aggiorna il profilo dell'utente
Future<void> updateDisplayName(String name) async {
  if (_profile == null) return;

  _setLoading(true);

  try {
    _error = null;
    _profile!.displayName = name;

    await _repo.updateProfile(_profile!);
  } catch (e) {
    _error = e.toString();
  } finally {
    _setLoading(false);
  }
}

// seleziona immagine e carica avatar
Future<void> pickAndUploadAvatar() async {
  if (_profile == null) return;

  try {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    _setLoading(true);
    _error = null;

    final user = Supabase.instance.client.auth.currentUser!;

    final path = 'image/${user.id}/avatar.jpg';

    await Supabase.instance.client.storage
        .from('image')
        .upload(
          path,
          File(image.path),
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    final avatarUrl = Supabase.instance.client.storage
        .from('image')
        .getPublicUrl(path);

    _profile!.avatarUrl =
        '$avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}';

    await _repo.updateProfile(_profile!);
  } catch (e) {
    _error = e.toString();
  } finally {
    _setLoading(false);
  }
}

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}