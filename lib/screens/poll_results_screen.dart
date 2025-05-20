import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import '../providers/pollsProvider.dart';
import '../providers/authProvider.dart';
import '../providers/languageProvider.dart';
import '../models/poll.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../Sidebars/govSidebar.dart';
import '../Sidebars/CitizenSidebar.dart';

class PollResultsScreen extends StatefulWidget {
  const PollResultsScreen({Key? key}) : super(key: key);

  @override
  State<PollResultsScreen> createState() => _PollResultsScreenState();
}

class _PollResultsScreenState extends State<PollResultsScreen> {
  final _translator = GoogleTranslator();
  Map<String, String> _translations = {};
  String _filterOption = 'all'; // 'all', 'active', 'completed'
  String _sortOption = 'newest'; // 'newest', 'oldest', 'most_votes', 'least_votes'
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<void> _pollsFuture;

  @override
  void initState() {
    super.initState();
    _loadPolls();
  }

  void _loadPolls() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pollsProvider = Provider.of<Pollsprovider>(context, listen: false);
    _pollsFuture = pollsProvider.fetchPollsFromServer(authProvider.token);
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  List<Poll> _filterAndSortPolls(List<Poll> polls) {
    // First apply search filter
    var filteredPolls = _searchQuery.isEmpty
        ? polls
        : polls.where((poll) =>
            poll.question.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Then apply status filter
    switch (_filterOption) {
      case 'active':
        filteredPolls = filteredPolls.where((poll) => 
          poll.endDate.isAfter(DateTime.now())).toList();
        break;
      case 'completed':
        filteredPolls = filteredPolls.where((poll) => 
          poll.endDate.isBefore(DateTime.now())).toList();
        break;
    }

    // Finally sort the polls
    switch (_sortOption) {
      case 'newest':
        filteredPolls.sort((a, b) => b.endDate.compareTo(a.endDate));
        break;
      case 'oldest':
        filteredPolls.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case 'most_votes':
        filteredPolls.sort((a, b) {
          final votesA = a.votes.values.fold<int>(0, (sum, v) => sum + (v is int ? v : 1));
          final votesB = b.votes.values.fold<int>(0, (sum, v) => sum + (v is int ? v : 1));
          return votesB.compareTo(votesA);
        });
        break;
      case 'least_votes':
        filteredPolls.sort((a, b) {
          final votesA = a.votes.values.fold<int>(0, (sum, v) => sum + (v is int ? v : 1));
          final votesB = b.votes.values.fold<int>(0, (sum, v) => sum + (v is int ? v : 1));
          return votesA.compareTo(votesB);
        });
        break;
    }

    return filteredPolls;
  }

  Widget _buildFilterBar(String currentLanguage) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          FutureBuilder<String>(
            future: _translateText('Search polls...', currentLanguage),
            builder: (context, searchHintSnapshot) {
              return TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: searchHintSnapshot.data ?? 'Search polls...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.search, 
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 22,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: FutureBuilder<String>(
                        future: _translateText('Filter by:', currentLanguage),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Filter by:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterOption,
                          isExpanded: true,
                          dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: FutureBuilder<String>(
                                future: _translateText('All Polls', currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'All Polls',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'active',
                              child: FutureBuilder<String>(
                                future: _translateText('Active Polls', currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Active Polls',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: FutureBuilder<String>(
                                future: _translateText('Completed Polls', currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Completed Polls',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterOption = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: FutureBuilder<String>(
                        future: _translateText('Sort by:', currentLanguage),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Sort by:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortOption,
                          isExpanded: true,
                          dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: [
                            DropdownMenuItem(
                              value: 'newest',
                              child: FutureBuilder<String>(
                                future: _translateText('Newest First', currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Newest First',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'oldest',
                              child: FutureBuilder<String>(
                                future: _translateText('Oldest First', currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Oldest First',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'most_votes',
                              child: FutureBuilder<String>(
                                future: _translateText('Most Votes', currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Most Votes',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'least_votes',
                              child: FutureBuilder<String>(
                                future: _translateText('Least Votes', currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Least Votes',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _sortOption = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollResultCard(Poll poll, String currentLanguage) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
    final totalVotes = poll.votes.values.fold(0, (sum, count) => sum + count);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: isDark ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FutureBuilder<String>(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: poll.endDate.isAfter(DateTime.now())
                        ? (isDark ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1))
                        : (isDark ? Colors.red.withOpacity(0.15) : Colors.red.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: poll.endDate.isAfter(DateTime.now())
                          ? (isDark ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.2))
                          : (isDark ? Colors.red.withOpacity(0.3) : Colors.red.withOpacity(0.2)),
                      width: 1,
                    ),
                  ),
                  child: FutureBuilder<String>(
                    future: _translateText(
                      poll.endDate.isAfter(DateTime.now()) ? 'Active' : 'Completed',
                      currentLanguage,
                    ),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? (poll.endDate.isAfter(DateTime.now()) ? 'Active' : 'Completed'),
                        style: TextStyle(
                          color: poll.endDate.isAfter(DateTime.now())
                              ? Colors.green[400]
                              : Colors.red[400],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...poll.options.map((option) {
              final votes = poll.votes[option] ?? 0;
              final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FutureBuilder<String>(
                              future: _translateText(option, currentLanguage),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? option,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                );
                              },
                            ),
                          ),
                          FutureBuilder<List<String>>(
                            future: Future.wait([
                              _translateText('vote', currentLanguage),
                              _translateText('votes', currentLanguage),
                            ]),
                            builder: (context, snapshot) {
                              final voteText = votes == 1
                                  ? (snapshot.data?[0] ?? 'vote')
                                  : (snapshot.data?[1] ?? 'votes');
                              return Text(
                                '$votes $voteText',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? primaryColor.withOpacity(0.8) 
                                  : primaryColor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            Divider(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              height: 24,
              thickness: 1,
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                FutureBuilder<List<String>>(
                  future: Future.wait([
                    _translateText('Live', currentLanguage),
                    _translateText('Total votes:', currentLanguage),
                  ]),
                  builder: (context, snapshot) {
                    final liveText = snapshot.data?[0] ?? 'Live';
                    final totalVotesText = snapshot.data?[1] ?? 'Total votes:';
                    return Text(
                      '$liveText  |  $totalVotesText $totalVotes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF5F5F7);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.isAdmin;

    return Scaffold(
      drawer: isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: isDark ? 0 : 1,
        iconTheme: IconThemeData(color: primaryColor),
        title: FutureBuilder<String>(
          future: _translateText('Poll Results', currentLanguage),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Poll Results',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            tooltip: 'Refresh',  // Add tooltip for accessibility
            onPressed: () {
              setState(() {
                _loadPolls();
              });
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: FutureBuilder<void>(
        future: _pollsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _translateText('Loading polls...', currentLanguage),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading polls...',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: isDark ? Colors.red[300] : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _translateText('Error loading polls', currentLanguage),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Error loading polls',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _translateText('Tap to retry', currentLanguage),
                    builder: (context, snapshot) {
                      return TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _loadPolls();
                          });
                        },
                        icon: Icon(Icons.refresh, color: primaryColor),
                        label: Text(
                          snapshot.data ?? 'Tap to retry',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return Consumer<Pollsprovider>(
            builder: (context, pollsProvider, child) {
              if (pollsProvider.polls.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.poll_outlined,
                        size: 48,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<String>(
                        future: _translateText('No polls available', currentLanguage),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'No polls available',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              final filteredPolls = _filterAndSortPolls(pollsProvider.polls);

              return Column(
                children: [
                  _buildFilterBar(currentLanguage),
                  if (filteredPolls.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<String>(
                              future: _translateText('No polls match your filters', currentLanguage),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'No polls match your filters',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<String>(
                              future: _translateText('Try adjusting your filters', currentLanguage),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'Try adjusting your filters',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[500] : Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredPolls.length,
                        itemBuilder: (context, index) {
                          return _buildPollResultCard(filteredPolls[index], currentLanguage);
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
} 