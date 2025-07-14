import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';
import '../providers/note_provider.dart';
import 'notes/widgets/location_section_widget.dart';
import 'notes/widgets/note_form_fields_widget.dart';
import 'notes/widgets/note_screen_actions.dart';

class NoteScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteScreen({Key? key, this.note}) : super(key: key);

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late DateTime _selectedDate;
  GeoPoint? _currentLocation;

  bool _isSavingOrDeleting = false;
  bool _hasUnsavedChanges = false;
  late AnimationController _saveButtonController;
  late Animation<double> _saveButtonAnimation;
  late NoteScreenActions _actions;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _setupChangeListeners();
    _actions = NoteScreenActions(ref, context);
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
    _selectedDate = widget.note?.date ?? DateTime.now();
    _currentLocation = widget.note?.location;
  }

  void _setupAnimations() {
    _saveButtonController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );
    _saveButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _saveButtonController, curve: Curves.easeInOut),
    );
    _saveButtonController.forward();
  }

  void _setupChangeListeners() {
    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _saveButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors from notesProvider
    ref.listen<NotesState>(notesProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
        ref.read(notesProvider.notifier).clearError();
      }
    });

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: _handlePopInvoked,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      title: Text(
        widget.note == null ? 'New Note' : 'Edit Note',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: _handleBackPressed,
      ),
      actions: [
        if (widget.note != null)
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _isSavingOrDeleting ? null : _deleteNote,
            tooltip: 'Delete Note',
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            NoteFormFieldsWidget(
              titleController: _titleController,
              bodyController: _bodyController,
              selectedDate: _selectedDate,
              onDateTap: _selectDate,
              isEnabled: !_isSavingOrDeleting,
            ),
            
            SizedBox(height: 20.h),
            
            LocationSectionWidget(
              initialLocation: _currentLocation,
              onLocationChanged: _handleLocationUpdate,
              isLoading: _isSavingOrDeleting,
            ),

            SizedBox(height: 40.h),
            _buildSaveButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ScaleTransition(
      scale: _saveButtonAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _isSavingOrDeleting ? null : _saveNote,
          child: _isSavingOrDeleting
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      widget.note == null ? 'Creating...' : 'Updating...',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.note == null ? Icons.add : Icons.save, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      widget.note == null ? 'Create Note' : 'Save Changes',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Event Handlers
  void _handleLocationUpdate(GeoPoint? location) {
    setState(() {
      _currentLocation = location;
      if (location != null) {
        _hasUnsavedChanges = true;
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await _actions.selectDate(_selectedDate);
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _handleBackPressed() async {
    if (_hasUnsavedChanges) {
      final shouldPop = await _actions.showUnsavedChangesDialog();
      if (shouldPop == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handlePopInvoked(bool didPop) async {
    if (!didPop && _hasUnsavedChanges) {
      final shouldPop = await _actions.showUnsavedChangesDialog();
      if (shouldPop == true && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _saveNote() async {
    await _actions.saveNote(
      formKey: _formKey,
      existingNote: widget.note,
      title: _titleController.text,
      body: _bodyController.text,
      date: _selectedDate,
      location: _currentLocation,
      onSaving: () => setState(() {
        _isSavingOrDeleting = true;
      }),
      onSaved: () => setState(() {
        _isSavingOrDeleting = false;
        _hasUnsavedChanges = false;
      }),
    );
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) return;
    
    await _actions.deleteNote(
      note: widget.note!,
      onDeleting: () => setState(() {
        _isSavingOrDeleting = true;
      }),
      onDeleted: () => setState(() {
        _isSavingOrDeleting = false;
      }),
    );
  }
}