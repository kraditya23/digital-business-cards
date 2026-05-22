import 'package:card_app/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:card_app/models/user_data.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class UserCard extends StatelessWidget {
  final UserData data;
  final Widget? editIcon;

  const UserCard({super.key, required this.data, this.editIcon});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> validSocialLinks =
        (data.socialIcons != null && data.socialUrl != null)
            ? List.generate(data.socialIcons!.length, (index) {
              return {
                'icon': data.socialIcons![index],
                'url': data.socialUrl![index],
                'name':
                    (data.socialNames != null &&
                            index < data.socialNames!.length)
                        ? data.socialNames![index]
                        : 'Social Link',
              };
            }).where((item) => item['url']!.isNotEmpty).toList()
            : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            elevation: 1,
            color: cardBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      (data.coverPicUrl != null &&
                                              data.coverPicUrl!.isNotEmpty)
                                          ? CachedNetworkImageProvider(
                                            data.coverPicUrl!,
                                          )
                                          : const AssetImage(defaultCover)
                                              as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Positioned(
                              bottom: -50,
                              left: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 56,
                                    backgroundImage:
                                        (data.profilePicUrl != null &&
                                                data.profilePicUrl!.isNotEmpty)
                                            ? CachedNetworkImageProvider(
                                              data.profilePicUrl!,
                                            )
                                            : const AssetImage(defaultAvatar)
                                                as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 17),
                        (editIcon != null)
                            ? editIcon!
                            : const SizedBox(height: 50),
                        Text(
                          data.name ?? data.username,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.9,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 2),
                        if ((data.jobTitle?.isNotEmpty ?? false) &&
                            (data.organisation?.isNotEmpty ?? false)) ...[
                          Text(
                            '${data.jobTitle ?? ''}, ${data.organisation ?? ''}',
                          ),
                        ] else if (data.jobTitle?.isNotEmpty ?? false) ...[
                          Text(data.jobTitle ?? ''),
                        ] else if (data.organisation?.isNotEmpty ?? false) ...[
                          Text(data.organisation ?? ''),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ============= DYNAMIC CONTENT SECTIONS =============
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Social Links (only if valid links exist)
              if (validSocialLinks.isNotEmpty) ...[
                _buildSectionHeader('Connect With Me'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      validSocialLinks
                          .map(
                            (item) => _buildSocialChip(
                              context,
                              iconUrl:
                                  'assets/icons/social_icons/${item['name'].toString().toLowerCase()}.png',
                              url: item['url']!,
                              name: item['name']!,
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // About Me Section
              if (data.aboutMe != null && data.aboutMe!.isNotEmpty) ...[
                _buildSectionHeader('About Me'),
                const SizedBox(height: 8),
                Text(
                  data.aboutMe!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // External Links
              if (data.linksText != null &&
                  data.linkUrl != null &&
                  data.linksText!.isNotEmpty &&
                  data.linkUrl!.isNotEmpty) ...[
                _buildSectionHeader(data.linkSectionHeader ?? 'My Links'),
                const SizedBox(height: 12),
                ...List.generate(data.linksText!.length, (index) {
                  if (index >= data.linkUrl!.length ||
                      data.linkUrl![index].isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLinkTile(
                      context,
                      title: data.linksText![index],
                      url: data.linkUrl![index],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Scheduling Link
              if (data.scheduling != null && data.scheduling!.isNotEmpty) ...[
                _buildSectionHeader('Schedule Time'),
                const SizedBox(height: 12),
                _buildScheduleButton(context, url: data.scheduling!),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSocialChip(
    BuildContext context, {
    required String iconUrl,
    required String url,
    required String name,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _launchURL(context, url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(iconUrl, width: 15, height: 15),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _launchURL(context, url),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.link_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleButton(BuildContext context, {required String url}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _launchURL(context, url),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.8), primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book an appointment',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Schedule time with me',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open the link'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
