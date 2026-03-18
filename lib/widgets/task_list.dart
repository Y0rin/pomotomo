import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> _tasks = [];
  String? _editingId;
  final _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await StorageService.loadTasks();
    setState(() => _tasks = tasks);
  }

  Future<void> _saveTasks() async {
    await StorageService.saveTasks(_tasks);
  }

  void _addTask() {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New task',
    );
    setState(() => _tasks.add(task));
    _saveTasks();
    // Auto-edit the new task
    _startEditing(task);
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
    _saveTasks();
  }

  void _startEditing(Task task) {
    setState(() {
      _editingId = task.id;
      _editController.text = task.title;
    });
  }

  void _finishEditing(int index) {
    if (_editController.text.trim().isNotEmpty) {
      setState(() {
        _tasks[index] = _tasks[index].copyWith(title: _editController.text.trim());
        _editingId = null;
      });
      _saveTasks();
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AppSettings>().accentColor;
    final opacity = context.watch<AppSettings>().cardOpacity;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.checklist_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Tasks',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _addTask,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_rounded, color: accent, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Task items
          if (_tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No tasks yet — tap + to add one',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            )
          else
            ..._tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              final isEditing = _editingId == task.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: () => _toggleDone(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: task.isDone
                              ? accent.withValues(alpha: 0.8)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.isDone
                                ? accent
                                : Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: task.isDone
                            ? const Icon(Icons.check, color: Colors.black, size: 14)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title or edit field
                    Expanded(
                      child: isEditing
                          ? TextField(
                              controller: _editController,
                              autofocus: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _finishEditing(index),
                            )
                          : GestureDetector(
                              onTap: () => _startEditing(task),
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  color: task.isDone
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                    ),

                    // Delete button
                    GestureDetector(
                      onTap: () => _deleteTask(index),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}