import 'package:flutter/material.dart';

/// PermissionButton Widget
///
/// Reusable button specifically for permission requests
/// Provides consistent styling and feedback
class PermissionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const PermissionButton({
    Key? key,
    required this.onPressed,
    this.label = 'Grant Permission',
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PermissionButton> createState() => _PermissionButtonState();
}

class _PermissionButtonState extends State<PermissionButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _handlePressed,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.location_on),
        label: Text(widget.isLoading ? 'Processing...' : widget.label),
      ),
    );
  }

  Future<void> _handlePressed() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
