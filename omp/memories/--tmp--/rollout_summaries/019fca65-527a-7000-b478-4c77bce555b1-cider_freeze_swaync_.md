thread_id: 019fca65-527a-7000-b478-4c77bce555b1
updated_at: 1785807507

Diagnosed and fixed Cider (music player) freezing after playing a track on a Linux system using SwayNotificationCenter (swaync). Root cause: swaync's DBus notification service was hanging, and Cider froze when trying to emit native playback notifications, causing MPRIS/Next timeouts.
