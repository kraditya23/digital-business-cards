import 'package:card_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:card_app/widgets/snackbars.dart';

class SchedulingPage extends ConsumerStatefulWidget {
  const SchedulingPage({super.key});

  @override
  ConsumerState<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends ConsumerState<SchedulingPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(userProvider).value?.scheduling ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _urlValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your scheduling link.';
    }
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL (e.g., https://example.com).';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final schedulingLink = ref.watch(userProvider).value?.scheduling ?? '';
    final userNotifier = ref.read(userProvider.notifier);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scheduling Link',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload your scheduling software link below so that people can take appointments directly by visiting your scheduling page.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Current Scheduling Link',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (schedulingLink.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              schedulingLink,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                decoration: TextDecoration.underline,
                                decorationColor: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      if (await canLaunchUrl(
                                        Uri.parse(schedulingLink),
                                      )) {
                                        await launchUrl(
                                          Uri.parse(schedulingLink),
                                        );
                                      } else {
                                        context.showErrorSnackBar(
                                          message: 'Could not open link',
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open Link'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: schedulingLink),
                                      );
                                      context.showNeutralSnackBar(
                                        message: 'Link copied to clipboard!',
                                        icon: Icons.copy,
                                      );
                                    },
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copy Link'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: colorScheme.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Text(
                          'No scheduling link uploaded yet. Please add one below.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter New Scheduling Link',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Scheduling Link URL',
                          hintText: 'https://your-scheduling-software.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        autofillHints: const [AutofillHints.url],
                        validator: _urlValidator,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isSaving
                                  ? null
                                  : () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      setState(() => _isSaving = true);
                                      try {
                                        await userNotifier.updateSchedulingLink(
                                          _controller.text.trim(),
                                        );
                                        context.showSuccessSnackBar(
                                          message:
                                              'Scheduling link updated successfully!',
                                        );
                                      } catch (e) {
                                        context.showErrorSnackBar(
                                          message:
                                              'Failed to update link: ${e.toString()}',
                                        );
                                      } finally {
                                        setState(() => _isSaving = false);
                                      }
                                    }
                                  },
                          icon:
                              _isSaving
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save Link'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
