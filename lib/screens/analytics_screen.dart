import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pollsProvider.dart';
import '../providers/authProvider.dart';
import '../models/poll.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../Sidebars/govSidebar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch polls when the screen is first loaded
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<Pollsprovider>(context, listen: false).fetchPollsFromServer(authProvider.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const GovSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              Provider.of<Pollsprovider>(context, listen: false).fetchPollsFromServer(authProvider.token);
            },
          ),
        ],
      ),
      body: Consumer<Pollsprovider>(
        builder: (context, pollsProvider, child) {
          if (pollsProvider.polls.isEmpty) {
            return const Center(
              child: Text('No polls available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Analytics Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3B2A),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildSummaryCards(pollsProvider.polls),
                const SizedBox(height: 30),
                _buildPollAnalytics(pollsProvider.polls),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildSummaryCards(List<Poll> polls) {
    final totalPolls = polls.length;
    final activePolls = polls.where((poll) => poll.endDate.isAfter(DateTime.now())).length;
    final totalVotes = polls.fold<int>(
      0,
      (sum, poll) => sum + poll.votes.values.fold<int>(0, (s, v) => s + (v is int ? v : 1)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Polls',
              totalPolls.toString(),
              Icons.poll,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Active Polls',
              activePolls.toString(),
              Icons.how_to_vote,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Total Votes',
              totalVotes.toString(),
              Icons.people,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollAnalytics(List<Poll> polls) {
    if (polls.isEmpty) {
      return const Center(
        child: Text('No polls available for analytics'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Poll Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...polls.take(3).map((poll) => _buildPollResultCard(poll)),
        ],
      ),
    );
  }

  Widget _buildPollResultCard(Poll poll) {
    final percentages = _calculatePercentages(poll);
    final sections = _createPieChartSections(poll, percentages);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections.map((section) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: section.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${poll.options[sections.indexOf(section)]} (${section.value.toStringAsFixed(1)}%)',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(Poll poll, Map<String, double> percentages) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return poll.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final percentage = percentages[option] ?? 0.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Map<String, double> _calculatePercentages(Poll poll) {
    final totalVotes = poll.votes.values.fold<int>(
      0,
      (sum, v) => sum + (v is int ? v : 1),
    );

    if (totalVotes == 0) {
      return Map.fromIterable(
        poll.options,
        key: (option) => option,
        value: (_) => 100.0 / poll.options.length,
      );
    }

    return Map.fromIterable(
      poll.options,
      key: (option) => option,
      value: (option) {
        final votes = poll.votes[option] ?? 0;
        return (votes is int ? votes : 1) * 100.0 / totalVotes;
      },
    );
  }
} 