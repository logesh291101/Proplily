import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_properties_model.dart';
import 'package:proplilly/client/models/client_property_extensions.dart';
import 'package:proplilly/client/screens/client_edit_property_screen.dart';
import 'package:proplilly/client/services/client_my_properties_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

/// Lists user properties from `GET {live_url}/user/properties`.
class ClientMyPropertiesScreen extends StatefulWidget {
  const ClientMyPropertiesScreen({super.key});

  @override
  State<ClientMyPropertiesScreen> createState() =>
      _ClientMyPropertiesScreenState();
}

class _ClientMyPropertiesScreenState extends State<ClientMyPropertiesScreen> {
  final _service = ClientMyPropertiesService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientProperty> _loadedProperties = <ClientProperty>[];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.fetchProperties();
    if (!mounted) return;

    switch (result) {
      case ClientPropertiesFetchSuccess(:final model):
        setState(() {
          _isLoading = false;
          _loadedProperties =
              List<ClientProperty>.from(model.data ?? const []);
          _errorMessage = null;
        });
      case ClientPropertiesFetchFailure(:final message):
        setState(() {
          _isLoading = false;
          _loadedProperties = <ClientProperty>[];
          _errorMessage = message;
        });
    }
  }

  void _openEditProperty(ClientProperty property) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditPropertyScreen(
          property: property.toEditPropertyItem(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Properties'),
        actions: ProplillyAppBar.clientActions(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProplillyScreenHeroSection(
            title: 'My Properties',
            subtitle: 'View your properties and update details.',
            icon: Icons.home_work_outlined,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProperties,
              color: AppColors.primary,
              child: _buildBody(context, horizontal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, double horizontal) {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        children: [
          Text(
            'Loading properties...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (_) => const _PropertyCardSkeleton()),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: PremiumErrorState(
              message: _errorMessage!,
              onRetry: _loadProperties,
            ),
          ),
        ],
      );
    }

    if (_loadedProperties.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        children: const [
          SizedBox(height: 32),
          _MyPropertiesEmptyState(),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
      itemCount: _loadedProperties.length,
      itemBuilder: (context, index) {
        final property = _loadedProperties[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _loadedProperties.length - 1 ? 16 : 0,
          ),
          child: _MyPropertyCard(
            property: property,
            onEditDetails: () => _openEditProperty(property),
          ),
        );
      },
    );
  }
}

class _MyPropertyCard extends StatelessWidget {
  const _MyPropertyCard({
    required this.property,
    required this.onEditDetails,
  });

  final ClientProperty property;
  final VoidCallback onEditDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = property.photoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _PropertyImagePlaceholder(),
                errorWidget: (_, __, ___) => const _PropertyImagePlaceholder(),
              )
            else
              const _PropertyImagePlaceholder(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (property.propertyName?.trim().isNotEmpty ?? false)
                        ? property.propertyName!.trim()
                        : '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.displayPlotType != '—'
                        ? property.displayPlotType.toUpperCase()
                        : '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleSmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PropertyMetaLine(
                              label: 'Status',
                              value: property.monitoringStatus ?? '',
                              theme: theme,
                            ),
                            const SizedBox(height: 8),
                            _PropertyMetaLine(
                              label: 'City',
                              value: property.city ?? '',
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _EditDetailsButton(onPressed: onEditDetails),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyMetaLine extends StatelessWidget {
  const _PropertyMetaLine({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final TextTheme theme;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isNotEmpty ? value.trim() : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          display,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EditDetailsButton extends StatelessWidget {
  const _EditDetailsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            'Edit Details',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _PropertyImagePlaceholder extends StatelessWidget {
  const _PropertyImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark.withValues(alpha: 0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 56,
            color: AppColors.white.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 8),
          Text(
            'No image available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PropertyCardSkeleton extends StatelessWidget {
  const _PropertyCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.primaryLight.withValues(alpha: 0.18),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _MyPropertiesEmptyState extends StatelessWidget {
  const _MyPropertiesEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.home_work_outlined,
            size: 48,
            color: AppColors.primaryDark.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No properties found.',
          textAlign: TextAlign.center,
          style: theme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
