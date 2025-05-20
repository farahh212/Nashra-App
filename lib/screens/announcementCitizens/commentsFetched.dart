import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/models/comment.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:nashra_project2/providers/languageProvider.dart';

class CommentsFetched extends StatefulWidget {
  final Announcement announcement;

  const CommentsFetched({super.key, required this.announcement});

  @override
  State<CommentsFetched> createState() => _CommentsFetchedState();
}

class _CommentsFetchedState extends State<CommentsFetched> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingComment = false;
  bool isAnonymous = false;
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};
  String _tooltipText = 'Send comment';
  String _hintText = 'Write a comment...';
  String _closeText = 'Close';

  Future<String> _translateText(String text, String targetLang) async {
    final key = '${text}_$targetLang';
    if (_translations.containsKey(key)) {
      return _translations[key]!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations[key] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguageCode;
    
    _tooltipText = await _translateText('Send comment', currentLang);
    _hintText = await _translateText('Write a comment...', currentLang);
    _closeText = await _translateText('Close', currentLang);
    
    if (mounted) {
      setState(() {});
    }
  }

  void _loadComments() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
    announcementsProvider.fetchCommentsForAnnouncement(widget.announcement.id, auth.token);
  }

  Future<String?> getDisplayNameByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['name'];
    }
    return null;
  }

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      _isPostingComment = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final currentLang = languageProvider.currentLanguageCode;

      String? displayName;

      if (!isAnonymous) {
        displayName = await getDisplayNameByUid(auth.userId!);
      } else {
        displayName = await _translateText('Anonymous', currentLang);
      }

      final newComment = Comment(
        id: '',
        userId: auth.userId!,
        name: displayName,
        content: _commentController.text,
        anonymous: isAnonymous,
        createdAt: DateTime.now(),
      );

      await announcementsProvider.addCommentToAnnouncement(widget.announcement.id, newComment, auth.token);
      await announcementsProvider.fetchCommentsForAnnouncement(widget.announcement.id, auth.token);
      final announcementIndex = announcementsProvider.announcements.indexWhere((a) => a.id == widget.announcement.id);
      final currentAnnouncement = announcementsProvider.announcements.firstWhere(
        (a) => a.id == widget.announcement.id,
        orElse: () => widget.announcement,
      );

      _commentController.clear();
    } catch (e) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final currentLang = languageProvider.currentLanguageCode;
      final errorMessage = await _translateText('Failed to post comment', currentLang);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMessage: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isPostingComment = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLanguageCode;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder<String>(
                future: _translateText('Comments', currentLang),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Comments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.close, color: primaryColor),
                onPressed: () => Navigator.pop(context),
                tooltip: _closeText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<Announcementsprovider>(
              builder: (ctx, announcementsProvider, _) {
                final announcement = announcementsProvider.announcements.firstWhere(
                  (a) => a.id == widget.announcement.id,
                  orElse: () => widget.announcement,
                );

                final comments = announcement.comments;

                if (comments.isEmpty) {
                  return Center(
                    child: FutureBuilder<String>(
                      future: _translateText('No comments yet. Be the first to comment!', currentLang),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'No comments yet. Be the first to comment!',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (ctx, index) {
                    final comment = comments[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: ListTile(
                        title: FutureBuilder<String>(
                          future: _translateText(comment.name ?? 'Government', currentLang),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? (comment.name ?? 'Government'),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        subtitle: FutureBuilder<String>(
                          future: _translateText(comment.content, currentLang),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? comment.content,
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (!isAdmin) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAnonymous = !isAnonymous;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor,
                        width: 2,
                      ),
                      color: isAnonymous ? primaryColor : Colors.transparent,
                    ),
                    child: isAnonymous
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                FutureBuilder<String>(
                  future: _translateText('Anonymous', currentLang),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Anonymous',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: _hintText,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isPostingComment
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _postComment,
                        tooltip: _tooltipText,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
