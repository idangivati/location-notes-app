import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/note_provider.dart';
import 'notes/widgets/empty_state_widget.dart';
import 'notes/widgets/note_card_widget.dart';
import 'notes/widgets/error_state_widget.dart';

class NoteListScreen extends ConsumerWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);

    if (notesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notesState.error != null) {
      return ErrorStateWidget(
        error: notesState.error!,
        onRetry: () => ref.read(notesProvider.notifier).clearError(),
      );
    }

    if (notesState.notes.isEmpty) {
      return const EmptyStateWidget();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(notesProvider.notifier).clearError();
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final note = notesState.notes[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: NoteCardWidget(note: note, index: index),
                  );
                },
                childCount: notesState.notes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}