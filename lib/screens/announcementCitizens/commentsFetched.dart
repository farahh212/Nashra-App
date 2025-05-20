import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/models/comment.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:nashra_project2/services/text_moderation.dart'; // Add this import

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

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final announcementsProvider =
        Provider.of<Announcementsprovider>(context, listen: false);
    announcementsProvider.fetchCommentsForAnnouncement(
        widget.announcement.id, auth.token);
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

    setState(() => _isPostingComment = true);

    try {
      // Check content safety
      final isSafe = await TextModeration.isContentSafe(_commentController.text);
      if (!isSafe) {
        if (mounted) {
          final shouldPost = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Content Warning'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your comment contains language that may be harmful:'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _commentController.text,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Are you sure you want to post this?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('EDIT'),
                ),
              ],
            ),
          );

          if (shouldPost != true) {
            return; // User chose to edit
          }
        }
      }

      // Post the comment
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final announcementsProvider =
          Provider.of<Announcementsprovider>(context, listen: false);

      final newComment = Comment(
        id: '',
        userId: auth.userId!,
        name: isAnonymous ? 'Anonymous' : await getDisplayNameByUid(auth.userId!),
        content: _commentController.text,
        anonymous: isAnonymous,
        createdAt: DateTime.now(),
      );

      await announcementsProvider.addCommentToAnnouncement(
          widget.announcement.id, newComment, auth.token);
      await announcementsProvider.fetchCommentsForAnnouncement(
          widget.announcement.id, auth.token);

      if (mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment posted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
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
              Text(
                'Comments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: primaryColor),
                onPressed: () => Navigator.pop(context),
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
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
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
                        title: Text(
                          comment.name ?? 'Government',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          comment.content,
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
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
                Text(
                  "Anonymous",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
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
                      hintText: 'Write a comment...',
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