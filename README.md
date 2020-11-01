# App Launcher

**NOTE**: Work in progress.

Linux app launcher written in Flutter. It works on Wayland using layer-shell protocol, therefore it can only run on desktops implementing it. Same of those are:
- [Sway](https://swaywm.org/) (some issues at the moment, see [wmww/gtk-layer-shell#71](https://github.com/wmww/gtk-layer-shell/issues/71),
- [mate-wayland](https://snapcraft.io/mate-wayland).

Goals:
- [ ] Nice minimal materialish design.
- [ ] Quick search over desktop files.
- [ ] Launch apps via `gtk-launcher`.
- [ ] Maybe a simple calculator by executing one-line Python commands.