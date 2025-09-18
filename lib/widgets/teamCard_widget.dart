import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/models/team_model.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final VoidCallback? onTap;

  const TeamCard({
    Key? key,
    required this.team,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150, // Fixed width for horizontal list
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkBorder, width: 1),
          // Add a subtle shadow if desired, from AppTheme.cardShadow
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Team Logo
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.darkSurface,
                backgroundImage: NetworkImage(team.logoUrl), // Ensure logoUrl is valid
                onBackgroundImageError: (exception, stackTrace) {
                  // Fallback for broken image links
                  // print('Error loading team logo for ${team.name}: $exception');
                },
                child: team.logoUrl.isEmpty // Show initial if no logo URL
                    ? Text(
                        team.name.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(color: AppTheme.primaryColor),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              // Team Name
              Text(
                team.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Follower Count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_alt_outlined, color: AppTheme.mutedText, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${NumberFormat('#,##0').format(team.stats.followerCount)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}