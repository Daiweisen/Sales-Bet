import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/models/even_model.dart';
import 'package:sales_bets/providers/event_provider.dart';
import 'package:intl/intl.dart';
import 'package:sales_bets/views/Betting/betting_screen.dart';
import 'package:sales_bets/views/LiveStream/livestream_screen.dart';
import 'package:sales_bets/widgets/timer_widget.dart'; // Import the CountdownTimer widget

class EventScreen extends StatelessWidget {
  final String eventId;

  const EventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventProvider = Provider.of<EventsProvider>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<Event?>(
        future: eventProvider.getEventById(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!;
          final isLive = event.isLive;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, theme, event, isLive),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Countdown timer placed here
                      if (!isLive) // Only show the timer if the event is not live
                        CountdownTimer(endTime: event.startDate),
                      if (!isLive)
                        const SizedBox(height: 16),

                      _buildEventDetails(theme, event),
                      const SizedBox(height: 24),
                      // Conditionally show the live stream button
                      if (event.isLive && event.streamUrl != null)
                        _buildLiveStreamButton(context, theme, event),
                      const SizedBox(height: 16),
                      _buildBettingCallToAction(context, theme, event),
                      const SizedBox(height: 24),
                      _buildTeamsSection(theme, event),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, ThemeData theme, Event event, bool isLive) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        centerTitle: false,
        title: Text(
          event.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.lightText,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://picsum.photos/800/600?random=${event.id.hashCode}',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            if (isLive)
              Positioned(
                top: 50,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LIVE',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStreamButton(BuildContext context, ThemeData theme, Event event) {
    return ElevatedButton.icon(
      onPressed: () {
        if (event.streamUrl != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LiveStreamScreen(
                streamUrl: event.streamUrl!,
                eventTitle: event.title,
                eventId: event.id,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live stream URL is not available.')),
          );
        }
      },
      icon: const Icon(Icons.live_tv),
      label: const Text('Watch Live Stream'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        elevation: 4,
      ),
    );
  }

  Widget _buildEventDetails(ThemeData theme, Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Event',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          event.description,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          theme,
          icon: Icons.access_time_filled,
          label: 'Start Date',
          value: DateFormat('MMM dd, yyyy').format(event.startDate),
        ),
        _buildDetailRow(
          theme,
          icon: Icons.timelapse,
          label: 'End Date',
          value: DateFormat('MMM dd, yyyy').format(event.endDate),
        ),
        _buildDetailRow(
          theme,
          icon: Icons.category,
          label: 'Category',
          value: event.category,
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBettingCallToAction(BuildContext context, ThemeData theme, Event event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Prize Pot',
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.lightText),
          ),
          Text(
            '\$${NumberFormat('#,##0').format(event.totalPot)}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppTheme.lightText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BettingScreen(eventId: event.id),
                ),
              );
            },
            icon: const Icon(Icons.currency_exchange),
            label: const Text('Place Your No-Loss Bet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.darkText,
              elevation: 4,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsSection(ThemeData theme, Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participating Teams',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...event.participatingTeams.map((teamId) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '- Team ID: $teamId',
                style: theme.textTheme.bodyMedium,
              ),
            )).toList(),
      ],
    );
  }
}