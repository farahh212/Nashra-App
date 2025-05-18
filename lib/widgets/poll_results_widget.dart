import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/poll.dart';
import 'package:intl/intl.dart';

class PollResultsWidget extends StatelessWidget {
  final Poll poll;
  final Color primaryColor;
  final Color secondaryColor;

  const PollResultsWidget({
    Key? key,
    required this.poll,
    this.primaryColor = const Color(0xFF1A3B2A),
    this.secondaryColor = const Color(0xFF4CAF50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalVotes = poll.votes.values.fold<int>(0, (sum, votes) => sum + votes);
    final dataMap = _createDataMap();
    final colorList = _createColorList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Poll ends on ${DateFormat('MMMM d, y').format(poll.endDate)} · Total votes: ${NumberFormat('#,###').format(totalVotes)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ...poll.options.map((option) => _buildPollOption(
                option,
                poll.votes[option] ?? 0,
                totalVotes,
              )),
          const SizedBox(height: 30),
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: SizedBox(
              height: 200,
              child: PieChart(
                dataMap: dataMap,
                colorList: colorList,
                chartRadius: MediaQuery.of(context).size.width / 2.5,
                legendOptions: const LegendOptions(
                  showLegends: true,
                  legendPosition: LegendPosition.bottom,
                  legendTextStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: false,
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  decimalPlaces: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _createDataMap() {
    final totalVotes = poll.votes.values.fold<int>(0, (sum, votes) => sum + votes);
    return Map.fromEntries(
      poll.options.map((option) {
        final votes = poll.votes[option] ?? 0;
        final percentage = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;
        return MapEntry(option, percentage);
      }),
    );
  }

  List<Color> _createColorList() {
    return [
      primaryColor,
      secondaryColor,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ].take(poll.options.length).toList();
  }

  Widget _buildPollOption(String option, int votes, int totalVotes) {
    final percentage = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;
    final color = option == poll.options.first ? primaryColor : secondaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
} 