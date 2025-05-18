import 'package:flutter/material.dart';
import 'package:nashra_project2/models/poll.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:provider/provider.dart';
// import '../models/poll.dart';
// import '../providers/authProvider.dart';
// import '../providers/pollsProvider.dart';

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
    // Check if user has already voted
    final auth = Provider.of<AuthProvider>(context, listen: false);
      final isAdmin = auth.isAdmin;

    _selectedOption = widget.poll.voterToOption[auth.userId];
  }

  Future<void> _submitVote(String option) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_selectedOption != null) return;// Prevent multiple votes

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
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.poll.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.poll.imageUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              widget.poll.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.poll.options.map((option) {
              final isSelected = _selectedOption == option;
              final percentage = _getOptionPercentage(option);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: (_selectedOption == null && !_isSubmitting && !isAdmin)
    ? () => _submitVote(option)
    : null,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.green : null,
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                          if (_selectedOption != null || isAdmin)
                            Text(
                              '${(percentage * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 14),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                     
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSelected ? Colors.green : Colors.blue,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      if (_selectedOption != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            '${widget.poll.votes[option] ?? 0} votes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedOption == null && _isSubmitting)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}