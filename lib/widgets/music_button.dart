import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/music_service.dart';

/// Always-visible music ON/OFF control.
class MusicButton extends StatelessWidget {
  const MusicButton({super.key});

  @override
  Widget build(BuildContext context) {
    final music = MusicService.instance;
    return ListenableBuilder(
      listenable: music,
      builder: (context, _) {
        final on = music.isPlaying;
        return Semantics(
          button: true,
          label: on ? 'Turn music off' : 'Turn music on',
          child: Material(
            color: Colors.white.withAlpha(190),
            elevation: 3,
            shadowColor: AppColors.deepRose.withAlpha(80),
            shape: StadiumBorder(side: BorderSide(color: AppColors.rose.withAlpha(140))),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () async {
                final messenger = ScaffoldMessenger.maybeOf(context);
                await music.toggle();
                if (music.hasFailed) {
                  messenger?.showSnackBar(
                    const SnackBar(content: Text('Music could not be played on this device.')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(on ? Icons.music_note_rounded : Icons.music_off_rounded,
                        size: 20, color: AppColors.forest),
                    const SizedBox(width: 8),
                    Text(on ? 'Music ON' : 'Music OFF',
                        style: AppText.caps(11, letterSpacing: 1.2, weight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
