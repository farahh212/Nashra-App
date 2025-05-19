import 'package:flutter/material.dart';
import 'package:nashra_project2/models/poll.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:nashra_project2/screens/announcementCitizens/pollsComments.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2);

    return Card(
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: isDark ? 2 : 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.poll.question,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.poll.options.map((option) {
              final isSelected = _selectedOption == option;
              final percentage = _getOptionPercentage(option);
              final showResults = _selectedOption != null || isAdmin;
              final background = isDark 
                ? (showResults ? Colors.grey[800] : Colors.grey[900])
                : (showResults ? Colors.grey[100] : Colors.grey[50]);
              final progressColor = isSelected ? primaryColor : (isDark ? Colors.grey[700] : Colors.grey[400]);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: (_selectedOption == null && !_isSubmitting && !isAdmin)
                      ? () => _submitVote(option)
                      : null,
                  borderRadius: BorderRadius.circular(8.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                          ? primaryColor 
                          : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        width: isSelected ? 2 : 1,
                      ),
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
                                color: isSelected 
                                  ? primaryColor 
                                  : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            if (showResults)
                              Text(
                                '${(percentage * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: showResults ? percentage : 0,
                            minHeight: 8,
                            backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            if (_selectedOption == null && _isSubmitting)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
            if (_selectedOption != null || isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Live  |  $totalVotes votes',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height * 0.50,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Pollscomments(poll: widget.poll),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.mode_comment_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.poll.commentsNo ?? 0}',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}