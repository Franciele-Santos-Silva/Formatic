import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Task {
  final int? id;
  final String name;
  final String description;
  final Color color;
  final DateTime date;

  Task({
    this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'color': _colorToHex(color),
    'date': date.toIso8601String(),
  };

  static String _colorToHex(Color c) {
    // Gera string #AARRGGBB usando os novos acessores
    int a = (c.a * 255.0).round() & 0xff;
    int r = (c.r * 255.0).round() & 0xff;
    int g = (c.g * 255.0).round() & 0xff;
    int b = (c.b * 255.0).round() & 0xff;
    return '#'
            '${a.toRadixString(16).padLeft(2, '0')}'
            '${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  factory Task.fromJson(Map<String, dynamic> map) => Task(
    id: map['id'] is int
        ? map['id']
        : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    name: map['name'] as String,
    description: map['description'] as String,
    color: _parseColor(map['color'] as String),
    date: DateTime.parse(map['date'] as String),
  );

  static Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      colorString = colorString.substring(1);
    }
    if (colorString.length == 8) {
      return Color(int.parse(colorString, radix: 16));
    } else if (colorString.length == 6) {
      return Color(int.parse('FF$colorString', radix: 16));
    }
    return Colors.blue;
  }
}

class TaskManagerPage extends StatefulWidget {
  final bool isDarkMode;
  const TaskManagerPage({super.key, this.isDarkMode = false});

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  List<Task> _tasks = [];
  final String _prefsKey = 'tasks';
  final ScrollController _scrollController = ScrollController();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final List<dynamic> data = jsonDecode(jsonString);
      setState(() {
        _tasks = data.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  Future<void> _addTask(Task task) async {
    setState(() {
      _tasks.add(task);
    });
    await _saveTasks();
  }

  Future<void> _updateTask(Task task, int index) async {
    setState(() {
      _tasks[index] = task;
    });
    await _saveTasks();
  }

  Future<void> _deleteTask(int index) async {
    setState(() {
      _tasks.removeAt(index);
    });
    await _saveTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }

  void _showAddTaskDialog({Task? editTask, int? editIndex}) {
    String name = editTask?.name ?? '';
    String description = editTask?.description ?? '';
    final List<Color> availableColors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.orange,
      Colors.green,
    ];
    Color color = editTask?.color ?? availableColors[0];
    DateTime? date = editTask?.date;
    TimeOfDay? time = editTask != null
        ? TimeOfDay(hour: editTask.date.hour, minute: editTask.date.minute)
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                editTask == null ? 'Nova Tarefa' : 'Editar Tarefa',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Nome'),
                      controller: TextEditingController(text: name),
                      onChanged: (v) => name = v,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      controller: TextEditingController(text: description),
                      onChanged: (v) => description = v,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Cor:'),
                        const SizedBox(width: 8),
                        Row(
                          children: availableColors
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setStateDialog(() => color = c),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color == c
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: c,
                                        radius: 14,
                                        child: color == c
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 18,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Data:'),
                        const SizedBox(width: 8),
                        Text(
                          date == null
                              ? 'Selecione'
                              : '${date!.day}/${date!.month}/${date!.year}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: date ?? now,
                              firstDate: DateTime(now.year - 2),
                              lastDate: DateTime(now.year + 5),
                            );
                            if (picked != null) {
                              setStateDialog(() => date = picked);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text('Hora:'),
                        const SizedBox(width: 8),
                        Text(time?.format(context) ?? '--:--'),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setStateDialog(() => time = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(editTask == null ? 'Salvar' : 'Atualizar'),
                  onPressed: () async {
                    if (name.isNotEmpty && date != null && time != null) {
                      final dateTimeWithTime = DateTime(
                        date!.year,
                        date!.month,
                        date!.day,
                        time!.hour,
                        time!.minute,
                      );
                      if (editTask == null) {
                        await _addTask(
                          Task(
                            name: name,
                            description: description,
                            color: color,
                            date: dateTimeWithTime,
                          ),
                        );
                      } else if (editIndex != null) {
                        await _updateTask(
                          Task(
                            id: editTask.id,
                            name: name,
                            description: description,
                            color: color,
                            date: dateTimeWithTime,
                          ),
                          editIndex,
                        );
                      }
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final today = DateTime.now();
    // Tarefas para hoje (do mês/ano selecionado)
    final todayTasks = _tasks
        .where(
          (t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day,
        )
        .toList();
    // Tarefas do mês/ano selecionado
    final monthTasks = _tasks
        .where(
          (t) => t.date.year == _selectedYear && t.date.month == _selectedMonth,
        )
        .toList();
    // Todas as tarefas, ordenadas por data (mais próximas primeiro)
    final allTasks = List<Task>.from(_tasks)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calendar logic
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final weekDayOffset = firstDayOfMonth.weekday % 7;
    final days = List.generate(daysInMonth, (i) => i + 1);
    final taskDays = monthTasks.map((t) => t.date.day).toSet();

    void scrollToTaskOfDay(int day) {
      final idx = allTasks.indexWhere(
        (t) =>
            t.date.day == day &&
            t.date.month == _selectedMonth &&
            t.date.year == _selectedYear,
      );
      if (idx != -1) {
        _scrollController.animateTo(
          idx * 100.0, // Aproximação da altura do card
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }

    // Listas para seleção de mês/ano
    final List<String> monthNames = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    final List<int> yearList = List.generate(8, (i) => today.year - 2 + i);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Tarefas para hoje
          Text(
            'Tarefas para hoje',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          if (todayTasks.isEmpty)
            Text(
              'Nenhuma tarefa para hoje',
              style: TextStyle(color: textColor.withAlpha((0.7 * 255).toInt())),
            ),
          ...todayTasks.map(
            (t) => _TaskCard(
              task: t,
              textColor: textColor,
              onEdit: () =>
                  _showAddTaskDialog(editTask: t, editIndex: _tasks.indexOf(t)),
              onDelete: () async {
                final idx = _tasks.indexOf(t);
                if (idx != -1) await _deleteTask(idx);
              },
            ),
          ),
          const SizedBox(height: 28),
          // Calendário
          Text(
            'Calendário',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Seleção de mês e ano
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: _selectedMonth,
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(monthNames[i]),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedMonth = v);
                      },
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _selectedYear,
                      items: yearList
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text(y.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedYear = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: [
                    for (int i = 0; i < weekDayOffset; i++)
                      const SizedBox(width: 36, height: 36),
                    for (final d in days)
                      GestureDetector(
                        onTap: taskDays.contains(d)
                            ? () => scrollToTaskOfDay(d)
                            : null,
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: taskDays.contains(d)
                                ? theme.colorScheme.primary.withAlpha(60)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              d.toString(),
                              style: TextStyle(
                                color: taskDays.contains(d)
                                    ? theme.colorScheme.primary
                                    : textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Todas as tarefas
          Text(
            'Todas as tarefas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          if (allTasks.isEmpty)
            Text(
              'Nenhuma tarefa criada',
              style: TextStyle(color: textColor.withAlpha((0.7 * 255).toInt())),
            ),
          ...allTasks.map(
            (t) => _TaskCard(
              task: t,
              textColor: textColor,
              onEdit: () =>
                  _showAddTaskDialog(editTask: t, editIndex: _tasks.indexOf(t)),
              onDelete: () async {
                final idx = _tasks.indexOf(t);
                if (idx != -1) await _deleteTask(idx);
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final Color textColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TaskCard({
    required this.task,
    required this.textColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? task.color.withAlpha((0.18 * 255).toInt())
            : task.color.withAlpha((0.10 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: task.color, radius: 10),
              const SizedBox(width: 8),
              Text(
                task.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                onPressed: onDelete,
                tooltip: 'Apagar',
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(
                color: textColor.withAlpha((0.85 * 255).toInt()),
              ),
            ),
          ],
          Row(
            children: [
              const Spacer(),
              Text(
                '${task.date.day}/${task.date.month}/${task.date.year} ${task.date.hour.toString().padLeft(2, '0')}:${task.date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: textColor.withAlpha((0.7 * 255).toInt()),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
