import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/note.dart';
import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/note_provider.dart';

class NoteScreenActions {
  final WidgetRef ref;
  final BuildContext context;

  NoteScreenActions(this.ref, this.context);

  Future<void> saveNote({
    required GlobalKey<FormState> formKey,
    required Note? existingNote,
    required String title,
    required String body,
    required DateTime date,
    required GeoPoint? location,
    required VoidCallback onSaving,
    required VoidCallback onSaved,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (location == null) {
      _showSnackBar(AppConstants.locationRequiredError, isError: true);
      return;
    }

    onSaving();

    final notesNotifier = ref.read(notesProvider.notifier);
    final userId = ref.read(authProvider).user?.uid;

    if (userId == null) {
      _showSnackBar(AppConstants.userNotLoggedInError, isError: true);
      onSaved();
      return;
    }

    try {
      if (existingNote == null) {
        final newNote = Note(
          id: '',
          userId: userId,
          title: title.trim(),
          body: body.trim(),
          date: date,
          location: location,
        );
        await notesNotifier.addNote(newNote);
        _showSnackBar(AppConstants.noteCreatedSuccess, isError: false);
      } else {
        final updatedNote = existingNote.copyWith(
          title: title.trim(),
          body: body.trim(),
          date: date,
          location: location,
        );
        await notesNotifier.updateNote(updatedNote);
        _showSnackBar(AppConstants.noteUpdatedSuccess, isError: false);
      }
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('Error saving note: $e', isError: true);
    } finally {
      onSaved();
    }
  }

  Future<void> deleteNote({
    required Note note,
    required VoidCallback onDeleting,
    required VoidCallback onDeleted,
  }) async {
    final bool? confirmed = await _showDeleteDialog();
    if (confirmed != true) return;

    onDeleting();

    final notesNotifier = ref.read(notesProvider.notifier);
    try {
      await notesNotifier.deleteNote(note.id);
      _showSnackBar(AppConstants.noteDeletedSuccess, isError: false);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('Error deleting note: $e', isError: true);
    } finally {
      onDeleted();
    }
  }

  Future<bool?> showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> selectDate(DateTime currentDate) async {
    return await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.error),
              SizedBox(width: 8.w),
              const Text('Delete Note'),
            ],
          ),
          content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20.w,
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}