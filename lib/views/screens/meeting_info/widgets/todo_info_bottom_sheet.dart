import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/controllers/todo_controller.dart';
import 'package:scribe/core/enums/priority_level.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/models/todo_model.dart';
import 'package:scribe/views/widgets/primary_button.dart';
import 'package:scribe/views/widgets/primary_button_with_icon.dart';

class TodoInfoButtomSheet {
  static Future showTodoInfoButtomSheet(
    BuildContext context, {
    required TodoModel todo,
    required int todoIndex,
    required String meetingId,
    VoidCallback? onTodoDeleted,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _TodoInfoButtomSheetContent(
        todo: todo,
        todoIndex: todoIndex,
        meetingId: meetingId,
        onTodoDeleted: onTodoDeleted,
      ),
    );
  }
}

class _TodoInfoButtomSheetContent extends ConsumerStatefulWidget {
  final TodoModel todo;
  final String meetingId;
  final int todoIndex;
  final VoidCallback? onTodoDeleted;

  const _TodoInfoButtomSheetContent({
    required this.meetingId,
    required this.todoIndex,
    required this.todo,
    this.onTodoDeleted,
  });

  @override
  ConsumerState<_TodoInfoButtomSheetContent> createState() =>
      _EditMeetingBottomSheetContentState();
}

class _EditMeetingBottomSheetContentState
    extends ConsumerState<_TodoInfoButtomSheetContent> {
  final TextEditingController todoController = TextEditingController();
  late PriorityLevel selectedPriority;

  @override
  void initState() {
    todoController.text = widget.todo.title;
    selectedPriority = PriorityLevel.fromString(widget.todo.priority);
    todoController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  bool isTodoChanged() {
    return widget.todo.title != todoController.text ||
        selectedPriority != PriorityLevel.fromString(widget.todo.priority);
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final isChanged = isTodoChanged();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag holder
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightBlackColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: AppColors.lightBlackColor,
                    ),
                    borderRadius: BorderRadius.circular(130),
                  ),
                  child: DropdownButton(
                    padding: EdgeInsets.all(0),
                    underline: SizedBox(),
                    value: selectedPriority,
                    items: PriorityLevel.values.map((PriorityLevel priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          spacing: 4,
                          children: [
                            Icon(
                              priority.icon,
                              color: priority.color,
                              size: 16,
                            ),
                            Text(priority.text),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (PriorityLevel? value) {
                      if (value != null) {
                        setState(() {
                          selectedPriority = value;
                        });
                      }
                    },
                  ),
                ),
                PrimaryButtonWithIcon(
                  text: "Delete To-Do",
                  icon: Icons.delete_outline,
                  foregroundColor: AppColors.whiteColor,
                  backgroundColor: AppColors.redColor,
                  onTap: () {
                    UserFeedback.showCustomDialog(
                      context: context,
                      title: "Delete To-Do",
                      description: "Once Deleted, Cannot Undo !",
                      confirmText: "Delete",
                      onConfirm: () async {
                        try {
                          await TodoController().deleteTodo(
                            widget.todoIndex,
                            widget.meetingId,
                          );
                          // Close the confirmation dialog
                          context.pop();
                          // Close the bottom sheet
                          context.pop();
                          // Call the callback to refresh the parent
                          if (widget.onTodoDeleted != null) {
                            widget.onTodoDeleted!();
                          }
                          UserFeedback.showInfoSnackbar(
                            context,
                            "To-Do deleted successfully",
                          );
                        } catch (e) {
                          context.pop();
                          UserFeedback.showErrorSnackbar(
                            context,
                            "Failed to delete To-Do",
                          );
                        }
                      },
                      onCancel: () {
                        context.pop();
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: todoController,
              decoration: InputDecoration(labelText: "To-Do"),
              maxLines: null,
            ),
            SizedBox(height: 20),
            PrimaryButton(
              height: 50,
              text: "Update Changes",
              backgroundColor: isChanged
                  ? AppColors.iconButtonColor
                  : AppColors.lightBlackColor,
              textColor: AppColors.whiteColor,
              onTap: isChanged
                  ? () async {
                      try {
                        final TodoModel updatedTodo = TodoModel(
                          todoId: widget.todo.todoId,
                          meetingId: widget.todo.meetingId,
                          title: todoController.text,
                          isCompleted: widget.todo.isCompleted,
                          priority: selectedPriority.text,
                        );
                        TodoController().updateTodo(
                          updatedTodo,
                          widget.meetingId,
                        );
                        if (context.mounted) {
                          context.pop();
                          UserFeedback.showSuccessSnackbar(
                            context,
                            "Todo Updated Successfully",
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          UserFeedback.showErrorSnackbar(
                            context,
                            "Failed to Update To-Do",
                          );
                        }
                      }
                    }
                  : () {}, // Empty function when disabled
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
