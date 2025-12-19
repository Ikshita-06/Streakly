import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart'; // To get the 'supabase' client variable
import 'theme_provider.dart';

class DashboardPage extends StatefulWidget {
  final Session session;
  const DashboardPage({super.key, required this.session});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> _habits = [];
  bool _isLoading = true;
  final _newHabitController = TextEditingController();
  final Set<int> _completedToday = {};

  final List<String> _exampleHabits = [
    'e.g., Read 20 Pages',
    'e.g., Code for 30 minutes',
    'e.g., Go for a walk',
    'e.g., Drink 8 glasses of water',
    'e.g., Meditate for 5 minutes',
    'e.g., No sugar today',
    'e.g., Practice guitar',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getHabitsAndLogs();
    });
  }

  Future<void> _performDailyStreakCheck() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;

    final userId = widget.session.user.id;

    final habitsToCheck = await supabase
        .from('habits')
        .select('id, current_streak')
        .eq('user_id', userId)
        .gt('current_streak', 0);

    List<int> habitsToReset = [];

    for (final habit in habitsToCheck) {
      final lastLog = await supabase
          .from('daily_logs')
          .select('date')
          .eq('habit_id', habit['id'])
          .order('date', ascending: false)
          .limit(1);

      if (lastLog.isEmpty) {
        habitsToReset.add(habit['id']);
      } else {
        final lastLogDate = lastLog[0]['date'];
        if (lastLogDate != today && lastLogDate != yesterday) {
          habitsToReset.add(habit['id']);
        }
      }
    }
    if (habitsToReset.isNotEmpty) {
      for (final habitId in habitsToReset) {
        await supabase
            .from('habits')
            .update({'current_streak': 0})
            .eq('id', habitId);
      }
    }
  }

  Future<void> _getHabitsAndLogs() async {
    setState(() { _isLoading = true; });

    try {
      await _performDailyStreakCheck();
      final habitsData = await supabase
          .from('habits')
          .select()
          .eq('user_id', widget.session.user.id)
          .order('created_at', ascending: false);

      final today = DateTime.now().toIso8601String().split('T').first;
      final logsData = await supabase
          .from('daily_logs')
          .select('habit_id')
          .eq('user_id', widget.session.user.id)
          .eq('date', today);

      if (mounted) {
        setState(() {
          _habits = List<Map<String, dynamic>>.from(habitsData);
          _completedToday.clear();
          for (final log in logsData) {
            _completedToday.add(log['habit_id']);
          }
        });
      }
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An unexpected error occurred'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _addHabit() async {
    final String name = _newHabitController.text.trim();
    if (name.isEmpty) return;

    try {
      final newHabit = await supabase
          .from('habits')
          .insert({
        'name': name,
        'user_id': widget.session.user.id,
      })
          .select()
          .single();

      if (mounted) {
        setState(() {
          _habits.insert(0, newHabit);
          _newHabitController.clear();
        });
      }
      Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _completeHabit(Map<String, dynamic> habit, int index) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;

    try {
      await supabase.from('daily_logs').upsert(
        {
          'habit_id': habit['id'],
          'user_id': widget.session.user.id,
          'date': today,
        },
        onConflict: 'habit_id, date',
      );

      final yesterdayLog = await supabase
          .from('daily_logs')
          .select('id')
          .eq('habit_id', habit['id'])
          .eq('date', yesterday);

      int newCurrentStreak = habit['current_streak'];
      int newLongestStreak = habit['longest_streak'];

      if (yesterdayLog.isNotEmpty) {
        newCurrentStreak += 1;
      } else {
        newCurrentStreak = 1;
      }

      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }

      final updatedHabit = await supabase
          .from('habits')
          .update({
        'current_streak': newCurrentStreak,
        'longest_streak': newLongestStreak,
      })
          .eq('id', habit['id'])
          .select()
          .single();

      if (mounted) {
        setState(() {
          _habits[index] = updatedHabit;
          _completedToday.add(habit['id']);
        });
      }
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteHabit(int habitId, int index) async {
    try {
      await supabase.from('habits').delete().eq('id', habitId);

      if (mounted) {
        setState(() {
          _habits.removeAt(index);
        });
      }
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to delete: ${error.message}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showAddHabitDialog() {
    final String randomHint =
    _exampleHabits[Random().nextInt(_exampleHabits.length)];

    _newHabitController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Habit'),
          content: TextFormField(
            controller: _newHabitController,
            decoration: InputDecoration(labelText: randomHint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addHabit,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int habitId, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Habit?'),
          content: const Text(
              'Are you sure you want to delete this habit and all its logs? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteHabit(habitId, index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = context.read<ThemeModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: Icon(themeModel.currentTheme == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeModel.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ))
          : ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          final bool isCompleted = _completedToday.contains(habit['id']);

          return ListTile(
            leading: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.grey,
              onPressed: () {
                _showDeleteConfirmationDialog(habit['id'], index);
              },
            ),
            title: Text(habit['name']),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (habit['current_streak'] > 0)
                  Icon(
                    Icons.local_fire_department,
                    color: habit['current_streak'] > 5
                        ? Colors.deepOrange
                        : Colors.orange,
                    size: 16,
                  ),
                if (habit['current_streak'] > 0)
                  const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Current: ${habit['current_streak']} / Longest: ${habit['longest_streak']}',
                    softWrap: true,
                  ),
                ),
              ],
            ),

            trailing: ElevatedButton(
              onPressed: isCompleted
                  ? null
                  : () => _completeHabit(habit, index),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isCompleted ? Colors.grey[700] : null,
                foregroundColor:
                isCompleted ? Colors.grey[400] : null,
              ),
              child: Text(isCompleted ? 'Done' : 'Complete'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add new habit',
      ),
    );
  }
}