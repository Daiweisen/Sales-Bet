import 'package:flutter/material.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/models/even_model.dart';
import 'package:intl/intl.dart'; // For date formatting, add to pubspec.yaml

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = event.isLive;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        color: AppTheme.darkCard, // Use dark card color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.darkBorder, width: 1),
        ),
        elevation: 0, // CardThemeData handles elevation
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Indicator or Category Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? AppTheme.errorColor : AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : event.category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isLive ? Colors.white : AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isLive)
                    Row(
                      children: [
                        const Icon(Icons.visibility, color: AppTheme.mutedText, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${event.viewerCount}',
                          style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.mutedText),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Event Title
              Text(
                event.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                event.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.greyText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Participating Teams (simplified for card)
              Text(
                'Teams: ${event.participatingTeams.join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Total Pot and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pot',
                        style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.mutedText),
                      ),
                      Text(
                        '\$${NumberFormat('#,##0').format(event.totalPot)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.accentColor, // Gold for earnings!
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Ends:',
                        style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.mutedText),
                      ),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(event.endDate),
                        style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.greyText),
                      ),
                    ],
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