import 'package:flutter/material.dart';
import 'package:nashra_project2/models/poll.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:provider/provider.dart';

class PollCard extends StatefulWidget {
  final Poll poll;
  const PollCard({super.key, required this.poll});

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  String? _selectedOption;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _selectedOption = widget.poll.voterToOption[auth.userId];
  }

  Future<void> _submitVote(String option) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_selectedOption != null) return;

    setState(() => _isSubmitting = true);
    final pollsProvider = Provider.of<Pollsprovider>(context, listen: false);

    try {
      await pollsProvider.updateVote(
        pollId: widget.poll.id,
        option: option,
        userId: auth.userId!,
        token: auth.token,
      );
      setState(() => _selectedOption = option);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit vote: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  double _getOptionPercentage(String option) {
    final totalVotes = widget.poll.votes.values.fold(0, (sum, count) => sum + count);
    if (totalVotes == 0) return 0.0;
    return (widget.poll.votes[option] ?? 0) / totalVotes;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isAdmin;
    final totalVotes = widget.poll.votes.values.fold(0, (sum, count) => sum + count);

    return Card(
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.poll.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),
            ...widget.poll.options.map((option) {
              final isSelected = _selectedOption == option;
              final percentage = _getOptionPercentage(option);
              final showResults = _selectedOption != null || isAdmin;
              final background = showResults ? Colors.grey[100] : Colors.grey[200];
              final progressColor = isSelected ? Color(0xFF1B5E20) : Colors.grey[400];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: (_selectedOption == null && !_isSubmitting && !isAdmin)
                      ? () => _submitVote(option)
                      : null,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Color(0xFF1B5E20) : Colors.black,
                              ),
                            ),
                            if (showResults)
                              Text(
                                '${(percentage * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: showResults ? percentage : 0,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            if (_selectedOption == null && _isSubmitting)
              const Center(child: CircularProgressIndicator()),
            if (_selectedOption != null || isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Color(0xFF1B5E20)),
                    const SizedBox(width: 6),
                    Text(
                      'Live  |  $totalVotes votes',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}