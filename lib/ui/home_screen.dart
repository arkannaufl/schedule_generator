import 'package:flutter/material.dart';
import 'package:flutter_schedule_generator/services/gemini_service.dart';
import '../models/tasks.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  bool isLoading = false;
  String scheduleResult = "";
  String? priority;
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  final deadlineController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6), // Soft Grayish Background
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildInputSection(),
          const SizedBox(height: 20),
          Expanded(child: _buildTaskList()),
          const SizedBox(height: 20),
          _buildGenerateButton(),
          const SizedBox(height: 20),
          _buildScheduleResult(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Text(
          "Schedule Generator",
          style: GoogleFonts.onest(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTextField(taskController, "Task Name", Icons.task),
            const SizedBox(height: 14),
            _buildTextField(durationController, "Duration (minutes)", Icons.timer, keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            _buildTextField(deadlineController, "Deadline", Icons.calendar_today),
            const SizedBox(height: 14),
            _buildDropdown(),
            const SizedBox(height: 20),
            _buildAddTaskButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.onest(),
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      keyboardType: keyboardType,
      style: GoogleFonts.onest(),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: priority,
      decoration: InputDecoration(
        labelText: "Priority",
        labelStyle: GoogleFonts.onest(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      items: const ["High", "Medium", "Low"]
          .map((priority) => DropdownMenuItem(
        value: priority,
        child: Text(priority, style: GoogleFonts.onest()),
      ))
          .toList(),
      onChanged: (value) => setState(() => priority = value),
      style: GoogleFonts.onest(),
    );
  }

  Widget _buildAddTaskButton() {
    return ElevatedButton(
      onPressed: _addTask,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: Text("Add Task", style: GoogleFonts.onest(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildTaskList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.task, color: Colors.blue.shade700),
              ),
              title: Text(task.name, style: GoogleFonts.onest(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "Priority: ${task.priority} | Duration: ${task.duration} min | Deadline: ${task.deadline}",
                style: GoogleFonts.onest(color: Colors.grey.shade600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => tasks.removeAt(index)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenerateButton() {
    return isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
      onPressed: _generateSchedule,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: Text("Generate Schedule", style: GoogleFonts.onest(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildScheduleResult() {
    return scheduleResult.isNotEmpty
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          scheduleResult,
          style: GoogleFonts.onest(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    )
        : Container();
  }

  void _addTask() {
    if (taskController.text.isNotEmpty && durationController.text.isNotEmpty && deadlineController.text.isNotEmpty && priority != null) {
      setState(() {
        tasks.add(Task(name: taskController.text, priority: priority!, duration: int.tryParse(durationController.text) ?? 5, deadline: deadlineController.text));
      });
      taskController.clear();
      durationController.clear();
      deadlineController.clear();
      priority = null;
    }
  }

  Future<void> _generateSchedule() async {
    setState(() => isLoading = true);
    scheduleResult = await GeminiService().generateSchedule(tasks);
    setState(() => isLoading = false);
  }
}