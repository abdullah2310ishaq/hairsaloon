import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/core/services/toast_service.dart';
import 'package:hairsaloon/src/features/sync/presentation/state/sync_store.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';
import 'package:provider/provider.dart';

class SyncOverlay extends StatelessWidget {
  const SyncOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SyncStore>();
    _maybeToastAfterFrame(store);
    final showExpanded = store.isExpanded;
    final showMinimized = store.isMinimized && !showExpanded;

    return Stack(
      children: [
        child,
        if (showExpanded)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12 + MediaQuery.of(context).padding.bottom + 72,
            child: const _ExpandedPanel(),
          )
        else if (showMinimized)
          Positioned(
            right: 12,
            bottom: 12 + MediaQuery.of(context).padding.bottom + 72,
            child: const _MinimizedChip(),
          ),
      ],
    );
  }

  void _maybeToastAfterFrame(SyncStore store) {
    if (store.completionNotified) return;
    if (store.status != SyncStatus.success && store.status != SyncStatus.failure) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store.completionNotified) return;
      store.markCompletionNotified();

      if (store.status == SyncStatus.success) {
        final at = store.lastSuccessAt;
        ToastService.success(
          at == null
              ? 'Sync completed'
              : 'Sync completed (${at.hour}:${at.minute.toString().padLeft(2, '0')})',
        );
        store.dismiss(); // auto-close modal when done
      } else if (store.status == SyncStatus.failure) {
        ToastService.error('Sync failed. Tap Sync Data to retry.');
      }
    });
  }
}

class _ExpandedPanel extends StatelessWidget {
  const _ExpandedPanel();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SyncStore>();
    final progress = store.total <= 0 ? 0.0 : (store.done / store.total).clamp(0.0, 1.0);

    final statusText = switch (store.status) {
      SyncStatus.idle => 'Ready',
      SyncStatus.running => 'Syncing…',
      SyncStatus.success => 'Synced',
      SyncStatus.failure => 'Failed',
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.cloud_upload, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cloud Sync',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => context.read<SyncStore>().minimize(),
                  icon: const Icon(CupertinoIcons.chevron_down, size: 18),
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _phaseLabel(store.phase),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  store.total <= 0 ? '' : '${store.done}/${store.total}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: store.status == SyncStatus.running ? progress : null,
                minHeight: 8,
                backgroundColor: const Color(0xFFEAEAEA),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            if (store.error != null && store.error!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  store.error!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: store.isRunning ? null : () => context.read<SyncStore>().startSync(),
                    child: Text(store.status == SyncStatus.failure ? 'Retry' : 'Sync Now'),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: store.isRunning ? null : () => context.read<SyncStore>().dismiss(),
                    child: const Icon(CupertinoIcons.xmark, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _phaseLabel(SyncPhase phase) {
    switch (phase) {
      case SyncPhase.idle:
        return 'Idle';
      case SyncPhase.profile:
        return 'Uploading business profile…';
      case SyncPhase.settings:
        return 'Uploading settings…';
      case SyncPhase.employees:
        return 'Uploading employees…';
      case SyncPhase.bills:
        return 'Uploading bills…';
      case SyncPhase.expenses:
        return 'Uploading expenses…';
      case SyncPhase.services:
        return 'Uploading services…';
      case SyncPhase.categories:
        return 'Uploading categories…';
      case SyncPhase.payouts:
        return 'Uploading payouts…';
      case SyncPhase.customerPhones:
        return 'Uploading customer phones…';
      case SyncPhase.customerContacts:
        return 'Uploading customer contacts…';
      case SyncPhase.done:
        return 'Done';
    }
  }
}

class _MinimizedChip extends StatelessWidget {
  const _MinimizedChip();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SyncStore>();
    final progress = store.total <= 0 ? 0 : ((store.done / store.total) * 100).round();
    final label = store.status == SyncStatus.running
        ? 'Syncing $progress%'
        : store.status == SyncStatus.success
            ? 'Synced'
            : store.status == SyncStatus.failure
                ? 'Sync failed'
                : 'Sync';

    final bg = store.status == SyncStatus.failure
        ? AppColors.danger
        : store.status == SyncStatus.success
            ? AppColors.success
            : AppColors.textPrimary;

    return GestureDetector(
      onTap: () => context.read<SyncStore>().expand(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.cloud_upload, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

