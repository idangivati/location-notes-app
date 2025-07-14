import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/constants.dart';

class NoteFormFieldsWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final DateTime selectedDate;
  final VoidCallback onDateTap;
  final bool isEnabled;

  const NoteFormFieldsWidget({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.selectedDate,
    required this.onDateTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateSection(context),
        SizedBox(height: 20.h),
        _buildTitleSection(),
        SizedBox(height: 20.h),
        _buildBodySection(),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: isEnabled ? onDateTap : null,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.textSecondary),
                SizedBox(width: 12.w),
                Text(
                  DateFormatter.formatFullDate(selectedDate),
                  style: TextStyle(fontSize: 16.sp),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: titleController,
          enabled: isEnabled,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter note title...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
          validator: Validators.validateNoteTitle,
          maxLines: 1,
          maxLength: AppConstants.maxNoteTitleLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            return Text(
              '$currentLength/$maxLength',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textTertiary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: bodyController,
          enabled: isEnabled,
          style: TextStyle(fontSize: 16.sp, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Write your note here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(16.w),
            alignLabelWithHint: true,
          ),
          validator: Validators.validateNoteBody,
          maxLines: 8,
          maxLength: AppConstants.maxNoteBodyLength,
          keyboardType: TextInputType.multiline,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            return Text(
              '$currentLength/$maxLength',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textTertiary,
              ),
            );
          },
        ),
      ],
    );
  }
}