import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/widgets/snackbars.dart';

class LinksPage extends ConsumerStatefulWidget {
  const LinksPage({super.key});

  @override
  ConsumerState<LinksPage> createState() => _LinksPageState();
}

class _LinksPageState extends ConsumerState<LinksPage>
    with TickerProviderStateMixin {
  List<TextEditingController> _linkTextControllers = [];
  List<TextEditingController> _linkUrlControllers = [];
  final TextEditingController _sectionHeaderController =
      TextEditingController();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Read the current state only once during initialization
    final userState = ref.read(userProvider);
    final user = userState.asData?.value;

    final linksText = user?.linksText ?? [];
    final linkUrl = user?.linkUrl ?? [];
    final header = user?.linkSectionHeader ?? '';

    _sectionHeaderController.text = header;
    _sectionHeaderController.addListener(_onTextChanged);

    // Ensure we have at least one pair of controllers
    final itemCount = linksText.isNotEmpty ? linksText.length : 1;

    _linkTextControllers = List.generate(itemCount, (index) {
      final controller = TextEditingController(
        text: linksText.length > index ? linksText[index] : '',
      );
      controller.addListener(_onTextChanged);
      return controller;
    });

    _linkUrlControllers = List.generate(itemCount, (index) {
      final controller = TextEditingController(
        text: linkUrl.length > index ? linkUrl[index] : '',
      );
      controller.addListener(_onTextChanged);
      return controller;
    });
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _sectionHeaderController.removeListener(_onTextChanged);
    _sectionHeaderController.dispose();

    for (var controller in _linkTextControllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    for (var controller in _linkUrlControllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewLinkField() {
    final newTextController = TextEditingController();
    final newUrlController = TextEditingController();

    newTextController.addListener(_onTextChanged);
    newUrlController.addListener(_onTextChanged);

    setState(() {
      _linkTextControllers.insert(0, newTextController);
      _linkUrlControllers.insert(0, newUrlController);
      _hasUnsavedChanges = true;
    });

    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _removeLinkField(int index) {
    if (_linkTextControllers.length <= 1) return;

    final removedTextController = _linkTextControllers[index];
    final removedUrlController = _linkUrlControllers[index];

    // Create a copy for the animation
    final textCopy = removedTextController.text;
    final urlCopy = removedUrlController.text;

    setState(() {
      _linkTextControllers.removeAt(index);
      _linkUrlControllers.removeAt(index);
      _hasUnsavedChanges = true;
    });

    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildAnimatedLinkCard(textCopy, urlCopy, animation),
      duration: const Duration(milliseconds: 300),
    );

    removedTextController.removeListener(_onTextChanged);
    removedUrlController.removeListener(_onTextChanged);
    removedTextController.dispose();
    removedUrlController.dispose();
  }

  Widget _buildAnimatedLinkCard(
    String textValue,
    String urlValue,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildLinkCardContent(
            TextEditingController(text: textValue),
            TextEditingController(text: urlValue),
            -1, // Invalid index to disable interactions
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final linksText = _linkTextControllers.map((c) => c.text.trim()).toList();
    final linkUrl = _linkUrlControllers.map((c) => c.text.trim()).toList();
    final header = _sectionHeaderController.text.trim();

    // Validation
    if (linksText.any((text) => text.isEmpty) ||
        linkUrl.any((url) => url.isEmpty)) {
      context.showErrorSnackBar(message: 'Please fill all fields');
      return;
    }

    if (linksText.length != linkUrl.length) {
      context.showErrorSnackBar(
        message: 'Each link text must have a corresponding URL',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a focused update that only affects the links section
      await ref
          .read(userProvider.notifier)
          .updateLinksSection(
            linksText: linksText,
            linkUrl: linkUrl,
            linkSectionHeader: header,
          );

      setState(() {
        _hasUnsavedChanges = false;
      });

      context.showSuccessSnackBar(message: 'Links updated successfully!');
    } catch (e) {
      context.showErrorSnackBar(
        message: 'Failed to update links: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLinkCardContent(
    TextEditingController textController,
    TextEditingController urlController,
    int index,
  ) {
    final theme = Theme.of(context);
    final isValidIndex = index >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.link,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Link ${isValidIndex ? index + 1 : ''}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isValidIndex && _linkTextControllers.length > 1)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      tooltip: 'Remove link',
                      onPressed: () => _removeLinkField(index),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              enabled: isValidIndex,
              decoration: InputDecoration(
                labelText: 'Link Display Text',
                hintText: 'e.g., Visit My Portfolio',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.text_fields,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              enabled: isValidIndex,
              decoration: InputDecoration(
                labelText: 'Link URL',
                hintText: 'https://example.com',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.link,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCard(int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildLinkCardContent(
            _linkTextControllers[index],
            _linkUrlControllers[index],
            index,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) {
        if (!didPop && _hasUnsavedChanges) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Unsaved Changes'),
                  content: const Text(
                    'You have unsaved changes. Are you sure you want to leave?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Leave'),
                    ),
                  ],
                ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.link,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Links',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_hasUnsavedChanges) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.title,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Section Header',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _sectionHeaderController,
                        decoration: InputDecoration(
                          labelText: 'Links Section Title',
                          hintText: 'e.g., Useful Links, Resources, etc.',
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Links List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: _linkTextControllers.length,
                    itemBuilder: (context, index, animation) {
                      return _buildLinkCard(index, animation);
                    },
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addNewLinkField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Link'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon:
                            _isLoading
                                ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                                : Icon(
                                  _hasUnsavedChanges ? Icons.save : Icons.check,
                                ),
                        label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
