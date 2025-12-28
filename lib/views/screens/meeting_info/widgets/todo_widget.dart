import 'package:flutter/material.dart';
import 'package:scribe/controllers/todo_controller.dart';
import 'package:scribe/core/enums/priority_level.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/models/todo_model.dart';
import 'package:scribe/views/screens/meeting_info/widgets/todo_info_bottom_sheet.dart';

class TodoWidget extends StatefulWidget {
  final List<TodoModel> todo;
  final String meetingId;
  final Future<void> Function()? onIsCompletedToggled;

  const TodoWidget({
    super.key,
    required this.todo,
    required this.meetingId,
    this.onIsCompletedToggled,
  });

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  late List<TodoModel> localTodos;

  @override
  void initState() {
    super.initState();
    localTodos = List.from(widget.todo);
  }

  @override
  void didUpdateWidget(TodoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todo != widget.todo) {
      localTodos = List.from(widget.todo);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (localTodos.isEmpty) {
      return Center(
        child: Text(
          "No To-Do Available",
          style: AppTextStyles.normalText.copyWith(color: AppColors.blackColor),
        ),
      );
    }

    return Center(
      child: ListView.builder(
        itemCount: localTodos.length,
        itemBuilder: (context, index) {
          final priority = PriorityLevel.fromString(localTodos[index].priority);

          // To-Do list
          return Container(
            margin: EdgeInsets.only(left: 12, right: 12, top: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.whiteColor,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 6),
              onTap: () {
                TodoInfoButtomSheet.showTodoInfoButtomSheet(
                  context,
                  todo: localTodos[index],
                  meetingId: widget.meetingId,
                  todoIndex: index,
                  onTodoDeleted: () async {
                    if (widget.onIsCompletedToggled != null) {
                      await widget.onIsCompletedToggled!();
                    }
                  },
                );
              },
              title: Text(
                localTodos[index].title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: localTodos[index].isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              leading: Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  shape: CircleBorder(),
                  value: localTodos[index].isCompleted,
                  onChanged: (value) async {
                    setState(() {
                      localTodos[index] = localTodos[index].copyWith(
                        isCompleted: value!,
                      );
                    });

                    // Update Firestore in background
                    await TodoController().toggleTodoIsComplete(
                      widget.meetingId,
                      localTodos[index].todoId,
                      value!,
                      onOptimisticUpdate: (updatedTodos) {},
                    );

                    if (widget.onIsCompletedToggled != null) {
                      await widget.onIsCompletedToggled!();
                    }
                  },
                ),
              ),

              // ToDo text
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(
                    width: 1,
                    color: priority.color.withOpacity(0.3),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: priority.color.withOpacity(0.2),
                      ),
                      child: Icon(
                        priority.icon,
                        color: priority.color,
                        size: 16,
                      ),
                    ),
                    Text(
                      priority.text.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: priority.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
