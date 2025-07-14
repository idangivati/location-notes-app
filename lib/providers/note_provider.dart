import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/note.dart';

class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;

  const NotesState({
    required this.notes,
    this.isLoading = false,
    this.error,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() {
    return 'NotesState(notesCount: ${notes.length}, isLoading: $isLoading, error: $error)';
  }
}

class NotesNotifier extends StateNotifier<NotesState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _notesSubscription;

  NotesNotifier(this._firebaseAuth, this._firestore)
      : super(const NotesState(notes: [], isLoading: true)) {
    _init();
  }

  void _init() {
    debugPrint('📓 NotesNotifier initialized');
    _authSubscription = _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('📓 User found, listening to notes: ${user.uid}');
        _listenToNotes(user.uid);
      } else {
        debugPrint('📓 User logged out, clearing notes');
        _cancelNotesSubscription();
        state = const NotesState(notes: [], isLoading: false);
      }
    });
  }

  void _cancelNotesSubscription() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
  }

  void _listenToNotes(String userId) {
    // Cancel any existing subscription
    _cancelNotesSubscription();
    
    debugPrint('📓 Starting to listen to notes for user: $userId');
    state = state.copyWith(isLoading: true, clearError: true);
    
    _notesSubscription = _firestore
        .collection('notes')
        .doc(userId)
        .collection('userNotes')
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          final notes = snapshot.docs
              .map((doc) => Note.fromFirestore(doc))
              .toList();
          
          debugPrint('📓 Notes updated successfully. Total notes: ${notes.length}');
          state = NotesState(
            notes: notes, 
            isLoading: false, 
            error: null,
          );
        } catch (e) {
          debugPrint('📓 Error parsing notes: $e');
          state = state.copyWith(
            isLoading: false, 
            error: 'Failed to parse notes: $e',
          );
        }
      },
      onError: (error) {
        debugPrint('📓 Error listening to notes: $error');
        state = state.copyWith(
          isLoading: false, 
          error: 'Failed to load notes: $error',
        );
      },
    );
  }

  @override
  void dispose() {
    debugPrint('📓 NotesNotifier disposed');
    _authSubscription?.cancel();
    _cancelNotesSubscription();
    super.dispose();
  }

  Future<void> addNote(Note note) async {
    debugPrint('📓 Attempting to add note: ${note.title}');
    
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      await _firestore
          .collection('notes')
          .doc(userId)
          .collection('userNotes')
          .add(note.toFirestore());

      debugPrint('📓 Note added successfully!');
    } catch (e) {
      debugPrint('📓 Error adding note: $e');
      state = state.copyWith(error: 'Failed to add note: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    debugPrint('📓 Attempting to update note: ${note.id} - ${note.title}');
    
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      await _firestore
          .collection('notes')
          .doc(userId)
          .collection('userNotes')
          .doc(note.id)
          .update(note.toFirestore());

      debugPrint('📓 Note updated successfully!');
    } catch (e) {
      debugPrint('📓 Error updating note: $e');
      state = state.copyWith(error: 'Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    debugPrint('📓 Attempting to delete note with ID: $noteId');
    
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      await _firestore
          .collection('notes')
          .doc(userId)
          .collection('userNotes')
          .doc(noteId)
          .delete();

      debugPrint('📓 Note deleted successfully!');
    } catch (e) {
      debugPrint('📓 Error deleting note: $e');
      state = state.copyWith(error: 'Failed to delete note: $e');
    }
  }

  void clearError() {
    if (state.error != null) {
      debugPrint('📓 Clearing notes error: ${state.error}');
      state = state.copyWith(clearError: true);
    }
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  return NotesNotifier(firebaseAuth, firestore);
});