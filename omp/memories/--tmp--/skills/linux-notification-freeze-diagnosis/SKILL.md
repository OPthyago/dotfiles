# Diagnosing App Freezes from Stuck DBus Notification Daemon (Sway/swaync)

Symptom: a desktop app (e.g. music/media player) hangs/freezes right after an event that would trigger an OS notification (e.g. track change), requiring a restart.

## Diagnosis
1. Check the app is actually stuck: `pgrep <app>`.
2. Find app config/log dirs: `~/.config/<app>` or reverse-DNS style dirs (e.g. `~/.config/sh.cider.genten`).
3. Grep logs for DBus timeout errors, e.g. `notify_notification_show ... timeout` or MPRIS call timeouts.
4. Test the notification daemon directly: call `org.freedesktop.Notifications.GetServerInformation` over DBus — if it hangs/fails, the daemon (swaync) itself is the root cause, not the app.

## Fix
1. Restart the notification daemon: `systemctl --user restart swaync.service` (or equivalent for your notification daemon).
2. If recurring, disable the app's native notifications in its own config (e.g. `playbackNotifications: false` in the app's yaml/config) as a workaround so it never blocks on DBus.

## Generalizes to
Any Linux app on Sway/wlroots using swaync (or similar notification daemons) that emits DBus notifications on state-change events — the notification call can block the whole app if the daemon is unresponsive.
