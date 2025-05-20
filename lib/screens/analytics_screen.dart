import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import '../providers/pollsProvider.dart';
import '../providers/authProvider.dart';
import '../providers/languageProvider.dart';
import '../models/poll.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../Sidebars/govSidebar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  final _translator = GoogleTranslator();
  Map<String, String> _translations = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<Pollsprovider>(context, listen: false).fetchPollsFromServer(authProvider.token);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> _translateText(String text, String targetLang) async {
    if (_translations.containsKey('${text}_$targetLang')) {
      return _translations['${text}_$targetLang']!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations['${text}_$targetLang'] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
    final backgroundColor = isDark ? theme.colorScheme.surface : Colors.white;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;

    return Scaffold(
      drawer: GovSidebar(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: () {
              _animationController.reset();
              _animationController.forward();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              Provider.of<Pollsprovider>(context, listen: false).fetchPollsFromServer(authProvider.token);
            },
          ),
        ],
      ),
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF5F5F7),
      body: Consumer<Pollsprovider>(
        builder: (context, pollsProvider, child) {
          if (pollsProvider.polls.isEmpty) {
            return Center(
              child: FutureBuilder<String>(
                future: _translateText('No polls available', currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'No polls available',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: FutureBuilder<String>(
                      future: _translateText('Analytics Dashboard', currentLanguage),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Analytics Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCards(pollsProvider.polls, currentLanguage),
                  const SizedBox(height: 20),
                  _buildPollAnalytics(pollsProvider.polls, currentLanguage),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Map<String, dynamic> _calculateAdvancedMetrics(List<Poll> polls) {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    
    // Participation rate calculation
    int totalVotes = 0;
    
    // Most engaging poll tracking
    Poll? mostEngagingPoll;
    int maxVotes = 0;

    for (var poll in polls) {
      // Calculate total votes for this poll
      final pollVotes = poll.votes.values.fold<int>(
        0,
        (sum, v) => sum + (v is int ? v : 1),
      );
      
      totalVotes += pollVotes;
      
      // Update most engaging poll
      if (pollVotes > maxVotes) {
        maxVotes = pollVotes;
        mostEngagingPoll = poll;
      }
    }

    // Calculate average votes per poll
    final averageVotes = polls.isEmpty ? 0 : (totalVotes / polls.length).round();

    return {
      'totalVotes': totalVotes,
      'mostEngagingPoll': mostEngagingPoll,
      'maxVotes': maxVotes,
      'averageVotesPerPoll': averageVotes,
      'recentPolls': polls.where((p) => p.endDate.isAfter(last30Days)).length,
    };
  }

  void _showDetailView(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String currentLanguage,
    String? subtitle,
    Map<String, dynamic>? additionalData,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 16),
              FutureBuilder<String>(
                future: _translateText(title, currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: _translateText(subtitle, currentLanguage),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? subtitle!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    );
                  },
                ),
              ],
              if (additionalData != null) ...[
                const SizedBox(height: 24),
                ...additionalData.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<String>(
                          future: _translateText(entry.key, currentLanguage),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? entry.key,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            );
                          },
                        ),
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: FutureBuilder<String>(
                  future: _translateText('Close', currentLanguage),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Close',
                      style: TextStyle(color: color),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedSizeCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String currentLanguage,
    String? subtitle,
    Map<String, dynamic>? additionalData,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showDetailView(
        context,
        title: title,
        value: value,
        icon: icon,
        color: color,
        currentLanguage: currentLanguage,
        subtitle: subtitle,
        additionalData: additionalData,
      ),
      child: SizedBox(
        width: width,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<String>(
                    future: _translateText(title, currentLanguage),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? title,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    FutureBuilder<String>(
                      future: _translateText(subtitle, currentLanguage),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? subtitle,
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Poll> polls, String currentLanguage) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final metrics = _calculateAdvancedMetrics(polls);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;
        return Column(
          children: [
            // First row
            SizedBox(
              height: 118,
              child: Row(
                children: [
                  _buildFixedSizeCard(
                    width: cardWidth,
                    title: 'Total Polls',
                    value: polls.length.toString(),
                    icon: Icons.poll,
                    color: isDark ? const Color(0xFF42A5F5) : const Color(0xFF1976D2),
                    currentLanguage: currentLanguage,
                    additionalData: {
                      'Active Polls': polls.where((poll) => poll.endDate.isAfter(DateTime.now())).length,
                      'Completed Polls': polls.where((poll) => poll.endDate.isBefore(DateTime.now())).length,
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildFixedSizeCard(
                    width: cardWidth,
                    title: 'Active Polls',
                    value: polls.where((poll) => poll.endDate.isAfter(DateTime.now())).length.toString(),
                    icon: Icons.how_to_vote,
                    color: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
                    currentLanguage: currentLanguage,
                  ),
                  const SizedBox(width: 16),
                  _buildFixedSizeCard(
                    width: cardWidth,
                    title: 'Total Votes',
                    value: metrics['totalVotes'].toString(),
                    icon: Icons.people,
                    color: isDark ? const Color(0xFF5C6BC0) : const Color(0xFF3949AB),
                    currentLanguage: currentLanguage,
                    additionalData: {
                      'Average Votes per Poll': metrics['averageVotesPerPoll'],
                      'Highest Votes in Single Poll': metrics['maxVotes'],
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Second row
            SizedBox(
              height: 118,
              child: Row(
                children: [
                  _buildFixedSizeCard(
                    width: cardWidth,
                    title: 'Recent Polls',
                    value: metrics['recentPolls'].toString(),
                    subtitle: 'Last 30 Days',
                    icon: Icons.update,
                    color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00),
                    currentLanguage: currentLanguage,
                  ),
                  const SizedBox(width: 16),
                  _buildFixedSizeCard(
                    width: cardWidth,
                    title: 'Highest Votes',
                    value: metrics['maxVotes'].toString(),
                    subtitle: 'Single Poll',
                    icon: Icons.trending_up,
                    color: isDark ? const Color(0xFF7E57C2) : const Color(0xFF5E35B1),
                    currentLanguage: currentLanguage,
                  ),
                  const SizedBox(width: 16),
                  _buildFixedSizeCard(
                    width: cardWidth,
                    title: 'Votes/Poll',
                    value: metrics['averageVotesPerPoll'].toString(),
                    subtitle: 'Average',
                    icon: Icons.analytics,
                    color: isDark ? const Color(0xFF4DD0E1) : const Color(0xFF00ACC1),
                    currentLanguage: currentLanguage,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPollAnalytics(List<Poll> polls, String currentLanguage) {
    final metrics = _calculateAdvancedMetrics(polls);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _translateText('Recent Poll Results', currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Recent Poll Results',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ...polls
              .where((poll) => poll.endDate.isAfter(DateTime.now().subtract(const Duration(days: 30))))
              .take(3)
              .map((poll) => _buildPollResultCard(poll, currentLanguage)),
        ],
      ),
    );
  }

  Widget _buildPollResultCard(Poll poll, String currentLanguage) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentages = _calculatePercentages(poll);
    final sections = _createPieChartSections(poll, percentages);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _translateText(poll.question, currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? poll.question,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
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
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      final option = poll.options[index];
                      final votes = poll.votes[option] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: FutureBuilder<String>(
                                future: Future.wait([
                                  _translateText(option, currentLanguage),
                                  _translateText('vote', currentLanguage),
                                  _translateText('votes', currentLanguage),
                                ]).then((translations) {
                                  final translatedOption = translations[0];
                                  final voteText = votes == 1 ? translations[1] : translations[2];
                                  return '$translatedOption\n$votes $voteText (${section.value.toStringAsFixed(1)}%)';
                                }),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? '$option\n$votes votes (${section.value.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? [
      const Color(0xFF42A5F5), // Blue
      const Color(0xFF66BB6A), // Green
      const Color(0xFF5C6BC0), // Indigo
      const Color(0xFFFFB74D), // Orange
      const Color(0xFF7E57C2), // Purple
      const Color(0xFF4DD0E1), // Cyan
    ] : [
      const Color(0xFF1976D2), // Blue
      const Color(0xFF2E7D32), // Green
      const Color(0xFF3949AB), // Indigo
      const Color(0xFFF57C00), // Orange
      const Color(0xFF5E35B1), // Purple
      const Color(0xFF00ACC1), // Cyan
    ];

    return poll.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final percentage = percentages[option] ?? 0.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: percentage,
        title: '',
        radius: 50,
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