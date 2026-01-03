import 'package:flutter/material.dart';
import '../models/recipe_comment.dart';
import '../services/comment_service.dart';

/// Comments section widget for recipe detail screens.
class CommentsSection extends StatefulWidget {
  final String recipeId;

  const CommentsSection({super.key, required this.recipeId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _textController = TextEditingController();
  final CommentService _commentService = CommentService();
  int _rating = 5;
  bool _isSubmitting = false;
  List<RecipeComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    _comments = await _commentService.getComments(widget.recipeId);
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.comment, color: Color(0xFFFF6347)),
              const SizedBox(width: 8),
              const Text(
                'Yorumlar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_comments.isNotEmpty)
                Text(
                  '(${_comments.length})',
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),
        ),

        // Add comment form
        _buildAddCommentForm(isDark),

        const Divider(),

        // Comments list
        _isLoading
            ? const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ))
            : _comments.isEmpty
                ? _buildEmptyState(isDark)
                : Column(
                    children: _comments.map((c) => CommentCard(
                      comment: c,
                      onHelpful: () => _commentService.markHelpful(widget.recipeId, c.id),
                    )).toList(),
                  ),
      ],
    );
  }

  Widget _buildAddCommentForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating stars
          Row(
            children: [
              const Text('Puanınız:'),
              const SizedBox(width: 12),
              ...List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Comment text field
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Yorumunuzu yazın...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.white,
            ),
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 12),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6347),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Yorum Gönder'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz yorum yok',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk yorumu siz yapın!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir yorum yazın')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _commentService.addComment(
        recipeId: widget.recipeId,
        rating: _rating,
        text: _textController.text.trim(),
      );

      _textController.clear();
      setState(() => _rating = 5);
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorumunuz eklendi! +15 XP 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

/// Single comment card widget.
class CommentCard extends StatelessWidget {
  final RecipeComment comment;
  final VoidCallback? onHelpful;

  const CommentCard({
    super.key,
    required this.comment,
    this.onHelpful,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info & rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFF6347).withOpacity(0.2),
                backgroundImage: comment.userAvatar != null
                    ? NetworkImage(comment.userAvatar!)
                    : null,
                child: comment.userAvatar == null
                    ? Text(
                        comment.userName.isNotEmpty
                            ? comment.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6347),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (comment.isPremium) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6347),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 10),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < comment.rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          comment.timeAgo,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment text
          Text(comment.text),

          // Images
          if (comment.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: comment.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        comment.images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Helpful button
          TextButton.icon(
            onPressed: onHelpful,
            icon: const Icon(Icons.thumb_up_outlined, size: 16),
            label: Text('Faydalı (${comment.helpfulCount})'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

/// Star rating display widget.
class RatingWidget extends StatelessWidget {
  final double rating;
  final int totalRatings;
  final bool showCount;
  final double size;

  const RatingWidget({
    super.key,
    required this.rating,
    this.totalRatings = 0,
    this.showCount = true,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, size: size, color: Colors.amber);
          } else if (index < rating) {
            return Icon(Icons.star_half, size: size, color: Colors.amber);
          } else {
            return Icon(Icons.star_border, size: size, color: Colors.amber);
          }
        }),
        if (showCount && totalRatings > 0) ...[
          const SizedBox(width: 8),
          Text(
            '${rating.toStringAsFixed(1)} ($totalRatings)',
            style: TextStyle(fontSize: size * 0.8, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
