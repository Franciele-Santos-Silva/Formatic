// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:formatic/core/theme/button_styles.dart';
import 'package:formatic/features/tasks/controllers/task_controller.dart';
import 'package:formatic/features/tasks/widgets/task_card_modern.dart';
import 'package:formatic/features/tasks/models/task_ui.dart';

class TaskManagerPage extends StatefulWidget {
  final bool isDarkMode;
  const TaskManagerPage({super.key, this.isDarkMode = false});

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  late final TaskController _controller;
  final ScrollController _scrollController = ScrollController();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TaskController();
    _loadTasks();
  }

  void _loadTasks() async {
    await _controller.loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showTaskDialog({TaskUI? editTask}) {
    String title = editTask?.title ?? '';
    String description = editTask?.description ?? '';
    const Color color = Color(0xFF8B2CF5); // Cor fixa
    DateTime? date = editTask?.dueDate;
    TimeOfDay? time = editTask?.dueTime;

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 550 ? 500 : screenWidth * 0.92,
                  maxHeight: screenHeight * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(
                      (screenWidth * 0.055).clamp(18.0, 24.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editTask == null ? 'Nova Tarefa' : 'Editar Tarefa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (screenWidth * 0.052).clamp(18.0, 22.0),
                          ),
                        ),
                        SizedBox(
                          height: (screenHeight * 0.018).clamp(14.0, 20.0),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Título',
                            labelStyle: TextStyle(
                              fontSize: (screenWidth * 0.038).clamp(14.0, 16.0),
                            ),
                            prefixIcon: Icon(
                              Icons.title,
                              size: (screenWidth * 0.055).clamp(20.0, 24.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                          ),
                          controller: TextEditingController(text: title),
                          onChanged: (v) => title = v,
                        ),
                        SizedBox(
                          height: (screenHeight * 0.015).clamp(12.0, 16.0),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Descrição',
                            labelStyle: TextStyle(
                              fontSize: (screenWidth * 0.038).clamp(14.0, 16.0),
                            ),
                            prefixIcon: Icon(
                              Icons.description,
                              size: (screenWidth * 0.055).clamp(20.0, 24.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                          ),
                          controller: TextEditingController(text: description),
                          maxLines: 3,
                          onChanged: (v) => description = v,
                        ),
                        SizedBox(
                          height: (screenHeight * 0.018).clamp(14.0, 20.0),
                        ),
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(
                                (screenWidth * 0.028).clamp(10.0, 12.0),
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📅 Data',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (screenWidth * 0.032).clamp(
                                        12.0,
                                        13.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: (screenHeight * 0.004).clamp(
                                      3.0,
                                      4.0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final now = DateTime.now();
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: date ?? now,
                                        firstDate: now,
                                        lastDate: DateTime(now.year + 5),
                                        builder: (BuildContext context, Widget? child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: Theme.of(context)
                                                  .colorScheme
                                                  .copyWith(
                                                    primary: color,
                                                    onPrimary: Colors.white,
                                                    surface: Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                                  ),
                                              datePickerTheme:
                                                  DatePickerThemeData(
                                                    backgroundColor: Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                                    headerBackgroundColor:
                                                        color,
                                                    headerForegroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    dayStyle: TextStyle(
                                                      fontSize:
                                                          (screenWidth * 0.036)
                                                              .clamp(
                                                                13.0,
                                                                15.0,
                                                              ),
                                                    ),
                                                    yearStyle: TextStyle(
                                                      fontSize:
                                                          (screenWidth * 0.036)
                                                              .clamp(
                                                                13.0,
                                                                15.0,
                                                              ),
                                                    ),
                                                  ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: color,
                                                      textStyle:
                                                          const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setStateDialog(() => date = picked);
                                      }
                                    },
                                    child: Text(
                                      date == null
                                          ? 'Selecione'
                                          : '${date!.day}/${date!.month}/${date!.year}',
                                      style: TextStyle(
                                        fontSize: (screenWidth * 0.04).clamp(
                                          14.0,
                                          16.0,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: (screenHeight * 0.012).clamp(10.0, 12.0),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(
                                (screenWidth * 0.028).clamp(10.0, 12.0),
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⏰ Hora',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (screenWidth * 0.032).clamp(
                                        12.0,
                                        13.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: (screenHeight * 0.004).clamp(
                                      3.0,
                                      4.0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: time ?? TimeOfDay.now(),
                                        builder: (BuildContext context, Widget? child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              timePickerTheme: TimePickerThemeData(
                                                backgroundColor: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                dialBackgroundColor: color
                                                    .withOpacity(0.1),
                                                dialHandColor: color,
                                                dialTextColor: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                                hourMinuteTextColor: color,
                                                hourMinuteColor: color
                                                    .withOpacity(0.15),
                                                dayPeriodTextColor: color,
                                                dayPeriodColor: color
                                                    .withOpacity(0.15),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                hourMinuteShape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: color,
                                                      textStyle:
                                                          const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setStateDialog(() => time = picked);
                                      }
                                    },
                                    child: Text(
                                      time?.format(context) ?? 'Selecione',
                                      style: TextStyle(
                                        fontSize: (screenWidth * 0.04).clamp(
                                          14.0,
                                          16.0,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: (screenHeight * 0.022).clamp(16.0, 24.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.038).clamp(
                                    14.0,
                                    16.0,
                                  ),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(
                              width: (screenWidth * 0.025).clamp(8.0, 12.0),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: (screenWidth * 0.055).clamp(
                                    18.0,
                                    24.0,
                                  ),
                                  vertical: (screenHeight * 0.012).clamp(
                                    10.0,
                                    12.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                editTask == null ? 'Criar' : 'Atualizar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: (screenWidth * 0.038).clamp(
                                    14.0,
                                    16.0,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                if (title.isNotEmpty &&
                                    date != null &&
                                    time != null) {
                                  final task = TaskUI(
                                    id: editTask?.id,
                                    title: title,
                                    description: description.isEmpty
                                        ? null
                                        : description,
                                    dueDate: date!,
                                    dueTime: time!,
                                    color: color,
                                    isCompleted: editTask?.isCompleted ?? false,
                                  );

                                  try {
                                    if (editTask == null) {
                                      await _controller.createTask(task);
                                    } else {
                                      await _controller.updateTask(task);
                                    }

                                    if (!context.mounted) return;

                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          editTask == null
                                              ? 'Tarefa criada com sucesso!'
                                              : 'Tarefa atualizada com sucesso!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Erro: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '⚠️ Preencha todos os campos',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _controller.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final filteredTasks = _controller.searchTasks(_searchQuery);
          filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

          final pendingTasks = filteredTasks
              .where((t) => !t.isCompleted)
              .toList();
          final completedTasks = filteredTasks
              .where((t) => t.isCompleted)
              .toList();

          final todayTasks = pendingTasks.where((t) {
            return t.dueDate.year == today.year &&
                t.dueDate.month == today.month &&
                t.dueDate.day == today.day;
          }).toList();

          final monthTasks = _controller.getTasksForMonth(
            _selectedYear,
            _selectedMonth,
          );

          final taskDays = monthTasks.map((t) => t.dueDate.day).toSet();

          final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
          final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);
          final daysInMonth = lastDayOfMonth.day;
          final weekDayOffset = firstDayOfMonth.weekday == 7
              ? 0
              : firstDayOfMonth.weekday;

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

          return RefreshIndicator(
            onRefresh: () async => _loadTasks(),
            child: Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? Colors.white.withOpacity(0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: widget.isDarkMode
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isDarkMode
                                ? Colors.black.withOpacity(0.35)
                                : const Color(0xFF8B2CF5).withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por tarefas...',
                          hintStyle: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black45,
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                            size: 24,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                        onChanged: (v) {
                          setState(() {
                            _searchQuery = v;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      ' Tarefas para hoje',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (todayTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.white.withOpacity(0.06)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isDarkMode
                                  ? Colors.black.withOpacity(0.35)
                                  : const Color(0xFF8B2CF5).withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Nenhuma tarefa para hoje!',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isDarkMode
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    if (todayTasks.isNotEmpty)
                      ...todayTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCardModern(
                            task: task,
                            onTap: () {},
                            onEdit: () => _showTaskDialog(editTask: task),
                            onDelete: () async {
                              if (task.id != null) {
                                try {
                                  await _controller.deleteTask(task.id!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🗑️ Tarefa removida'),
                                        backgroundColor: Color.fromARGB(
                                          255,
                                          255,
                                          0,
                                          0,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Erro ao remover: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            onToggleStatus: () async {
                              if (task.id != null) {
                                try {
                                  await _controller.toggleTaskStatus(task.id!);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Erro: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 32),
                    const Text(
                      'Calendário',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B2CF5), Color(0xFF7B1FA2)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B2CF5).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_selectedMonth == 1) {
                                      _selectedMonth = 12;
                                      _selectedYear--;
                                    } else {
                                      _selectedMonth--;
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  '${monthNames[_selectedMonth - 1]} $_selectedYear',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_selectedMonth == 12) {
                                      _selectedMonth = 1;
                                      _selectedYear++;
                                    } else {
                                      _selectedMonth++;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Table(
                            children: [
                              TableRow(
                                children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                                    .map(
                                      (d) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Center(
                                          child: Text(
                                            d,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
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
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cellSize = (constraints.maxWidth - 24) / 7;

                              final totalCells = weekDayOffset + daysInMonth;
                              final totalRows = (totalCells / 7).ceil();

                              final calendarCells = <Widget>[];

                              for (int i = 0; i < weekDayOffset; i++) {
                                calendarCells.add(
                                  SizedBox(width: cellSize, height: cellSize),
                                );
                              }

                              for (int d = 1; d <= daysInMonth; d++) {
                                final hasTask = taskDays.contains(d);
                                final isToday =
                                    d == today.day &&
                                    _selectedMonth == today.month &&
                                    _selectedYear == today.year;

                                calendarCells.add(
                                  Container(
                                    width: cellSize,
                                    height: cellSize,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: hasTask
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isToday
                                          ? Border.all(
                                              color: Colors.yellow,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        d.toString(),
                                        style: TextStyle(
                                          color: hasTask
                                              ? const Color(0xFF8B2CF5)
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final remainingCells =
                                  (totalRows * 7) - totalCells;
                              for (int i = 0; i < remainingCells; i++) {
                                calendarCells.add(
                                  SizedBox(width: cellSize, height: cellSize),
                                );
                              }

                              return GridView.count(
                                crossAxisCount: 7,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 0,
                                children: calendarCells,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Tarefas Pendentes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (pendingTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.white.withOpacity(0.06)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isDarkMode
                                  ? Colors.black.withOpacity(0.35)
                                  : const Color(0xFF8B2CF5).withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: widget.isDarkMode
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma tarefa pendente',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: widget.isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Clique no botão abaixo para criar sua primeira tarefa',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isDarkMode
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (pendingTasks.isNotEmpty)
                      ...pendingTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCardModern(
                            task: task,
                            onTap: () {},
                            onEdit: () => _showTaskDialog(editTask: task),
                            onDelete: () async {
                              if (task.id != null) {
                                try {
                                  await _controller.deleteTask(task.id!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Tarefa removida'),
                                        backgroundColor: Color.fromARGB(
                                          255,
                                          255,
                                          0,
                                          0,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Erro ao remover: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            onToggleStatus: () async {
                              if (task.id != null) {
                                try {
                                  await _controller.toggleTaskStatus(task.id!);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Erro: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 32),
                    if (completedTasks.isNotEmpty) ...[
                      const Text(
                        'Tarefas Completadas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...completedTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Opacity(
                            opacity: 0.7,
                            child: TaskCardModern(
                              task: task,
                              onTap: () {},
                              onEdit: () => _showTaskDialog(editTask: task),
                              onDelete: () async {
                                if (task.id != null) {
                                  try {
                                    await _controller.deleteTask(task.id!);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Tarefa removida'),
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            255,
                                            0,
                                            0,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ Erro ao remover: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              onToggleStatus: () async {
                                if (task.id != null) {
                                  try {
                                    await _controller.toggleTaskStatus(
                                      task.id!,
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('❌ Erro: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: ElevatedButton(
                    style: purpleElevatedStyle(radius: 20).copyWith(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 18),
                      ),
                      elevation: WidgetStateProperty.all(8),
                    ),
                    onPressed: () => _showTaskDialog(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Nova Tarefa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
