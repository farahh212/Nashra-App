class ContentWarningDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ContentWarningDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Content Warning'),
      content: const Text(
        'Your comment contains potentially harmful content. '
        'Are you sure you want to post it?',
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Edit'),
        ),

      ],
    );
  }
}