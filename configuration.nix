################################################################################
#                                                                              #
#   NixOS configuration for  samadams                                          #
#   A LARBS-flavoured suckless desktop: dwm + st + dmenu + dwmblocks           #
#                                                                              #
#   Upstream this is modelled on:                                              #
#     https://github.com/LukeSmithxyz/LARBS      (the installer / docs site)   #
#     https://github.com/LukeSmithxyz/dwm        (window manager + keybinds)   #
#     https://github.com/LukeSmithxyz/st         (terminal)                    #
#     https://github.com/LukeSmithxyz/dmenu      (launcher)                    #
#     https://github.com/LukeSmithxyz/dwmblocks  (status bar)                  #
#     https://github.com/LukeSmithxyz/voidrice   (dotfiles + helper scripts)   #
#                                                                              #
#   LARBS is an Arch install script. This file is a NixOS translation of it:   #
#   the same programs and the same keybindings, expressed declaratively.       #
#   Luke's dwm/st/dmenu are built from pinned upstream revisions, so the        #
#   keybinding table below is the real one, not an approximation.              #
#                                                                              #
#   ---------------------------------------------------------------------     #
#   USAGE                                                                      #
#   ---------------------------------------------------------------------     #
#     1. Generate hardware config (this file imports it):                      #
#          sudo nixos-generate-config                                          #
#     2. Copy this file over /etc/nixos/configuration.nix                      #
#     3. Set a password for the account after the first build:                 #
#          sudo passwd samadams                                                #
#     4. sudo nixos-rebuild switch                                             #
#                                                                              #
#   Press  Super+F1  inside the running system for the upstream dwm manual.    #
#                                                                              #
################################################################################

/*
════════════════════════════════════════════════════════════════════════════════
  L A R B S   K E Y B I N D I N G   R E F E R E N C E
  Mod key = Super (the "Windows" key).  Source of truth: LukeSmithxyz/dwm
  config.h at the revision pinned in section 2 of this file.
════════════════════════════════════════════════════════════════════════════════

  ── WINDOWS & STACK ──────────────────────────────────────────────────────────
  Super + j / k                 focus next / previous window in the stack
  Super + Shift + j / k         move the focused window down / up the stack
  Super + v                     focus the master window
  Super + Shift + v             move focused window into master
  Super + space                 zoom: promote focused window to master
  Super + Shift + space         toggle floating for the focused window
  Super + q                     close the focused window
  Super + Shift + q             sysact  (logout / reboot / shutdown menu)
  Super + f                     toggle fullscreen
  Super + h / l                 shrink / grow the master area
  Super + o / Shift + o         increase / decrease number of master windows
  Super + s                     toggle sticky (window follows you across tags)
  Super + b                     toggle the status bar
  Super + Tab                   jump back to the previously viewed tag
  Super + backslash             same as Super+Tab

  ── GAPS ─────────────────────────────────────────────────────────────────────
  Super + a                     toggle gaps on / off
  Super + Shift + a             reset gaps to their default size
  Super + z / x                 increase / decrease gaps
  Super + Shift + apostrophe    toggle "smart gaps" (no gaps when one window)

  ── LAYOUTS ──────────────────────────────────────────────────────────────────
  Super + t                     tile            [ ]=   master left, stack right
  Super + Shift + t             bstack          TTT    master top, stack bottom
  Super + y                     spiral          [@]    fibonacci spiral
  Super + Shift + y             dwindle         [\]    shrinking right/leftward
  Super + u                     deck            [D]    stack windows monocled
  Super + Shift + u             monocle         [M]    all windows stacked
  Super + i                     centeredmaster  |M|    master centred
  Super + Shift + i             centeredfloatingmaster >M>
  Super + Shift + f             floating        ><>    no tiling at all

  ── TAGS (workspaces) ────────────────────────────────────────────────────────
  Super + 1..9                  view tag N
  Super + Shift + 1..9          send focused window to tag N
  Super + Ctrl + 1..9           additively view tag N
  Super + Ctrl + Shift + 1..9   toggle tag N on the focused window
  Super + 0                     view all tags at once
  Super + Shift + 0             put focused window on every tag
  Super + g / semicolon         shift view one tag left / right
  Super + Shift + g / semicolon shift the focused window one tag left / right
  Super + PageUp / PageDown     shift view left / right (same as g / semicolon)

  ── MONITORS ─────────────────────────────────────────────────────────────────
  Super + Left / Right          focus the monitor to the left / right
  Super + Shift + Left / Right  send focused window to that monitor

  ── LAUNCHING PROGRAMS ───────────────────────────────────────────────────────
  Super + Return                terminal (st)
  Super + Shift + Return        drop-down scratchpad terminal
  Super + apostrophe            drop-down calculator (bc)
  Super + d                     dmenu_run   (run a command)
  Super + Shift + d             passmenu    (pick a password from pass)
  Super + w                     web browser (firefox — see section 2)
  Super + Shift + w             nmtui       (connect to wifi / network)
  Super + e                     neomutt     (email)
  Super + Shift + e             abook       (address book)
  Super + r                     lf          (file manager)
  Super + Shift + r             htop        (process viewer)
  Super + n                     vimwiki index in nvim
  Super + Shift + n             newsboat    (RSS)
  Super + m                     ncmpcpp     (music)
  Super + c                     profanity   (XMPP chat)
  Super + grave                 dmenuunicode (pick an emoji / unicode char)
  Super + Insert                paste a snippet from ~/.local/share/larbs/snippets
  Super + BackSpace             sysact

  ── ADDED BY THIS CONFIG (upstream leaves these unbound) ─────────────────────
  Super + Shift + c             vimb        (minimal vim-keys browser; this is
                                where surf would go — see section 2 for why it
                                is not installed by default)
  Super + Shift + b             ani-cli     (stream anime in the terminal)
  Super + Shift + s             virt-manager (QEMU/KVM virtual machines)
  Super + Shift + backslash     tmux, attaching to (or creating) session "main"
  Super + Shift + Tab           Tor Browser
  Super + Shift + Escape        fastfetch, held open until you press a key

  ── AUDIO & MUSIC (mpd via mpc) ──────────────────────────────────────────────
  Super + p                     pause / play
  Super + Shift + p             pause music and every running mpv
  Super + bracketleft/right     seek 10s back / forward
  Super + Shift + bracket…      seek 60s back / forward
  Super + comma / period        previous / next track
  Super + Shift + comma         restart the current track
  Super + Shift + period        toggle repeat
  Super + minus / equal         volume down / up 5%
  Super + Shift + minus/equal   volume down / up 15%
  Super + Shift + m             mute toggle

  ── FUNCTION KEYS ────────────────────────────────────────────────────────────
  Super + F1                    this keybinding manual, rendered as a PDF
  Super + F2                    tutorialvids   (Luke's videos)
  Super + F3                    displayselect  (multi-monitor arrangement)
  Super + F4                    pulsemixer     (audio mixer)
  Super + F5                    reload Xresources and restart dwmblocks
  Super + F6                    torwrap — despite the name this is about
                                TORRENTS, not Tor: it starts transmission-daemon
                                and opens the `stig` torrent client
  Super + F7                    td-toggle      (start/stop transmission-daemon)
  Super + F8                    mailsync       (sync mail)
  Super + F9                    mounter        (mount a drive / phone)
  Super + F10                   unmounter      (unmount it again)
  Super + F11                   show the webcam
  Super + F12                   remaps         (re-apply keyboard remaps)

  ── SCREENSHOTS & RECORDING ──────────────────────────────────────────────────
  PrintScreen                   screenshot the whole screen
  Shift + PrintScreen           maimpick   (menu: region, window, OCR, …)
  Super + PrintScreen           dmenurecord (start a screencast / audio rec)
  Super + Shift + PrintScreen   stop the recording
  Super + Delete                stop the recording
  Super + ScrollLock            toggle screenkey (show keypresses on screen)

  ── MOUSE ────────────────────────────────────────────────────────────────────
  Super + left-drag             move a window (makes it float)
  Super + right-drag            resize a window
  Super + middle-click          reset gaps to default
  Super + scroll on a window    increase / decrease gaps
  scroll on the tag bar         shift the view one tag left / right
  middle-click the window title zoom that window to master
  middle-click the desktop      toggle the bar
  left/right-click a tag        view / additively view that tag

  ── INSIDE st (THE TERMINAL) ─────────────────────────────────────────────────
  Alt + j / k, Alt + Up/Down    scroll through terminal history
  Alt + mouse wheel             scroll through terminal history
  Alt + u / d, Alt + PgUp/PgDn  scroll faster
  Alt + Shift + j / k           decrease / increase font size
  Alt + c                       copy the selection to the clipboard
  Shift + Insert                paste the clipboard
  Alt + l                       pick a URL from the screen and open it
  Alt + y                       pick a URL from the screen and copy it
  Alt + o                       copy the output of a recent command
  Alt + a / s                   decrease / increase transparency

  ── INSIDE lf (THE FILE MANAGER) ─────────────────────────────────────────────
  h j k l                       navigate, enter directories, open files
  g / G / Ctrl+d / Ctrl+u       movement, as in vim
  space                         select a file
  y / d / p                     yank / cut / paste selected files
  Y                             copy the file names to the system clipboard
  c / a / A / i / I             rename (at various cursor positions)
  B                             bulk rename every file in the directory
  w                             drop to a shell here (exit to come back)
  Ctrl + n                      create a new directory
  V                             create a new file in nvim
  s / z                         change sort order / show hidden files

  ── INSIDE zsh ───────────────────────────────────────────────────────────────
  Ctrl + o                      open lf; quitting cd's the shell to that dir
  Ctrl + f                      fzf-search for a file and cd to it
  Ctrl + a                      open bc for quick arithmetic (Ctrl+d exits)
  Ctrl + l                      clear the screen (works in vi normal mode too)

════════════════════════════════════════════════════════════════════════════════
*/

{ config, pkgs, lib, ... }:

let
  # ══════════════════════════════════════════════════════════════════════════
  #  0 · IDENTITY — change these, and the rest of the file follows
  # ══════════════════════════════════════════════════════════════════════════
  username = "samadams";
  fullName = "Sam Adams";
  # Your shell prompt is user@host, so this is what makes it `samadams@live`.
  hostName = "live";
  # Pinned so that /run/user/<uid> is predictable — mpd needs that path in
  # section 10 to find the user's PipeWire socket.
  userUid = 1000;

  # Seed Luke's dotfiles (lf, dunst, mpv, zathura, X resources, …) into the
  # user's home on first activation. Existing files are never overwritten;
  # see section 14 for exactly what this does and does not touch.
  seedLarbsDotfiles = true;

  # Terminal transparency. 1.0 is fully opaque, 0.0 invisible. Upstream ships
  # 0.8; this is lower so st is more see-through. Alt+a / Alt+s change it live
  # in a running terminal if you want to find your own number first.
  #
  # This value has to be applied in two places, because st reads `alpha` from
  # Xresources at startup and that silently overrides whatever is compiled in.
  # Section 2 patches both, so changing this one line is enough.
  stAlpha = "0.72";

  # ── BOOTLOADER ────────────────────────────────────────────────────────────
  # Getting these wrong is the most common reason a rebuild blows up. See the
  # troubleshooting block at the top of section 4 before changing them.

  # true = UEFI firmware. false = older BIOS/MBR machine.
  # Check with:  [ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
  useUEFI = true;

  # GRUB or systemd-boot?
  #
  # This is GRUB because you wanted a boot theme, and systemd-boot simply
  # cannot do that — it is a plain text menu drawn by the firmware, with no
  # theming support of any kind. GRUB draws its own graphical menu, so it is
  # the only one of the two that can be styled.
  #
  # Set false to go back to systemd-boot (simpler, faster, no theme).
  useGrub = true;

  # The theme itself. Both of these are packaged in nixpkgs and both were
  # checked to be real theme directories (a theme.txt plus its assets):
  #
  #   pkgs.catppuccin-grub                                    (mocha, default)
  #   pkgs.catppuccin-grub.override { flavor = "macchiato"; } (also: frappe, latte)
  #   pkgs.sleek-grub-theme.override { withStyle = "dark"; }  (also: light, orange, bigSur)
  #
  # Set to null for a plain unthemed GRUB.
  #
  # Defaulting to sleek/dark rather than catppuccin purely on size: catppuccin
  # is 2.7M (2.3M of that is one font file) against sleek's 392K, and /boot is
  # the one filesystem on this machine that is actually tight.
  grubTheme = pkgs.sleek-grub-theme.override { withStyle = "dark"; };

  # How many old generations to keep entries for in the boot menu.
  #
  # This is the setting that fills /boot. NixOS keeps a kernel AND an initrd
  # in /boot for every generation listed here, and those run 100-150M EACH.
  # At the previous value of 10 that is well over a gigabyte — more than most
  # EFI partitions hold, which is exactly the "No space left on device" you
  # hit. Three is plenty to roll back with.
  bootGenerationLimit = 3;

  # The theme needs a graphical mode to draw into. If the menu comes up
  # garbled or at the wrong size, try "auto", or match your panel exactly
  # (e.g. "1366x768"). "auto" is the safe fallback.
  grubResolution = "auto";

  # Where your EFI System Partition is mounted. NixOS's installer guide uses
  # /boot, but plenty of setups (and dual-boots alongside Windows) use
  # /boot/efi. Check with:  lsblk -f   — the ESP is the small vfat/FAT32 one.
  # If this does not match, systemd-boot installation fails.
  espMountPoint = "/boot";

  # Writing EFI variables fails on some firmware and in some VMs. If the
  # rebuild dies with an efivars / "Failed to write" style error, set this
  # false — the system still boots, you just have to pick NixOS in the
  # firmware boot menu the first time.
  touchEfiVars = true;

  # BIOS only: the DISK to install GRUB onto, not a partition.
  # /dev/sda and /dev/nvme0n1 are right; /dev/sda1 is wrong.
  grubDevice = "/dev/sda";

  # ══════════════════════════════════════════════════════════════════════════
  #  Extra dwm keybindings, injected into upstream's config.h.
  #  Kept in a separate C header so no shell quoting can mangle it. It is
  #  #include-d *inside* the keys[] array, after TERMINAL and SHCMD exist.
  # ══════════════════════════════════════════════════════════════════════════
  larbsExtraKeys = pkgs.writeText "larbs-extra-keys.h" ''
    /* Added by the NixOS configuration — upstream leaves these slots free. */
    /* Swap "vimb" for "surf" here if you enable surf in section 2. */
    { MODKEY|ShiftMask, XK_c,         spawn, {.v = (const char*[]){ "vimb", "https://duckduckgo.com", NULL } } },
    { MODKEY|ShiftMask, XK_b,         spawn, {.v = (const char*[]){ TERMINAL, "-e", "ani-cli", NULL } } },
    { MODKEY|ShiftMask, XK_s,         spawn, {.v = (const char*[]){ "virt-manager", NULL } } },
    { MODKEY|ShiftMask, XK_Tab,       spawn, {.v = (const char*[]){ "tor-browser", NULL } } },
    { MODKEY|ShiftMask, XK_backslash, spawn, {.v = (const char*[]){ TERMINAL, "-e", "tmux", "new-session", "-A", "-s", "main", NULL } } },
    { MODKEY|ShiftMask, XK_Escape,    spawn, SHCMD(TERMINAL " -e sh -c 'fastfetch; echo; printf \"[any key] \"; read -r _'") },
  '';

  # ══════════════════════════════════════════════════════════════════════════
  #  A default wallpaper, so something is always on screen at login.
  #  LARBS's `setbg` expects ~/.local/share/bg to exist and errors out when it
  #  does not — which is why a fresh install otherwise boots to a grey X root
  #  window. Section 8 falls back to this when you have not picked your own.
  #  Replace it any time with:  setbg /path/to/your/image.png
  # ══════════════════════════════════════════════════════════════════════════
  defaultWallpaper = pkgs.runCommand "larbs-default-wallpaper.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    magick -size 3840x2160 \
      gradient:'#0d1117-#1b2733' \
      -define png:color-type=2 \
      "$out"
  '';
in
{
  # ══════════════════════════════════════════════════════════════════════════
  #  1 · IMPORTS
  # ══════════════════════════════════════════════════════════════════════════
  # hardware-configuration.nix is machine specific and is NOT in this repo.
  # Generate it once with:  sudo nixos-generate-config
  imports = [
    ./hardware-configuration.nix
  ];

  # ══════════════════════════════════════════════════════════════════════════
  #  2 · THE SUCKLESS STACK — dwm, st, dmenu, dwmblocks, LARBS scripts
  #
  #  Each is built from a pinned upstream revision of Luke's fork, so the
  #  keybinding table at the top of this file is exactly what you get. To
  #  update, bump `rev` and run the build; Nix will print the correct hash.
  # ══════════════════════════════════════════════════════════════════════════
  nixpkgs.overlays = [
    (final: prev: {

      # ---- dwm: the window manager -------------------------------------
      larbs-dwm = prev.stdenv.mkDerivation {
        pname = "larbs-dwm";
        version = "6.5-larbs";

        src = prev.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "dwm";
          rev = "ee3354d54a51a14449a9ba93fe978c8a3a66db45";
          hash = "sha256-fQyhMa4gDD6EXH0hLDwU8tU7X4KUsuRlQu8saaoxfVM=";
        };

        nativeBuildInputs = [ prev.pkg-config ];
        buildInputs = with prev; [
          libx11        # core X client library (also provides libX11-xcb)
          libxinerama   # multi-monitor support
          libxft        # font drawing
          libxcb        # the swallow patch needs xcb-res
          fontconfig
          freetype
        ];

        postPatch = ''
          # Super+w should open the browser we actually install.
          substituteInPlace config.h \
            --replace-fail '#define BROWSER "librewolf"' '#define BROWSER "firefox"'

          # Super+F1 renders the manual; point it at the store, not /usr/local.
          substituteInPlace config.h \
            --replace-fail "/usr/local/share/dwm/larbs.mom" "$out/share/dwm/larbs.mom"

          # Splice in the extra bindings listed at the top of this file.
          cp ${larbsExtraKeys} larbs-extra-keys.h
          substituteInPlace config.h --replace-fail 'static const Key keys[] = {' 'static const Key keys[] = {
          #include "larbs-extra-keys.h"'
        '';

        # Upstream's config.mk hardcodes /usr/X11R6 and /usr/include; override.
        makeFlags = [
          "PREFIX=$(out)"
          "CC=cc"
          "FREETYPEINC=${prev.freetype.dev}/include/freetype2"
          "X11INC=${prev.libx11.dev}/include"
          "X11LIB=${prev.libx11}/lib"
        ];

        meta = {
          description = "Luke Smith's dwm build, as used by LARBS";
          homepage = "https://github.com/LukeSmithxyz/dwm";
          license = lib.licenses.mit;
          platforms = lib.platforms.linux;
          mainProgram = "dwm";
        };
      };

      # ---- st: the terminal --------------------------------------------
      larbs-st = prev.stdenv.mkDerivation {
        pname = "larbs-st";
        version = "0.8.5-larbs";

        src = prev.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "st";
          rev = "48b8ee6e181643800fe83353ec554f503020a8fa";
          hash = "sha256-XFf48+6I3IHcRKGHRJIJb9u2sTKWyuWTb5lN+BILYYc=";
        };

        nativeBuildInputs = [ prev.pkg-config prev.ncurses ];
        buildInputs = with prev; [
          libx11 libxft fontconfig freetype harfbuzz libxrender
        ];

        # Compiled-in transparency (see stAlpha in section 0). Note this is
        # only half the job — Xresources overrides it at runtime, so the
        # larbs-scripts derivation below patches that copy to match.
        postPatch = ''
          substituteInPlace config.h \
            --replace-fail 'float alpha = 0.8;' 'float alpha = ${stAlpha};'
        '';

        makeFlags = [ "PREFIX=$(out)" "CC=cc" ];

        # `make install` runs `tic`; send the terminfo into our own output
        # instead of trying to write to /usr/share.
        preInstall = ''
          export TERMINFO=$out/share/terminfo
          mkdir -p "$TERMINFO"
        '';

        meta = {
          description = "Luke Smith's st build (ligatures, scrollback, URL picker)";
          homepage = "https://github.com/LukeSmithxyz/st";
          license = lib.licenses.mit;
          platforms = lib.platforms.linux;
          mainProgram = "st";
        };
      };

      # ---- dmenu: the launcher -----------------------------------------
      larbs-dmenu = prev.stdenv.mkDerivation {
        pname = "larbs-dmenu";
        version = "5.0-larbs";

        src = prev.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "dmenu";
          rev = "c1819f18c07df6984bbfd2ca7207295eec85806f";
          hash = "sha256-QcnsD8h0uDjttqOHZwMWVA3Qp1eH/og5RrSeopnMILM=";
        };

        nativeBuildInputs = [ prev.pkg-config ];
        buildInputs = with prev; [
          libx11 libxinerama libxft fontconfig freetype libxrender
        ];

        makeFlags = [
          "PREFIX=$(out)"
          "CC=cc"
          "FREETYPEINC=${prev.freetype.dev}/include/freetype2"
          "X11INC=${prev.libx11.dev}/include"
          "X11LIB=${prev.libx11}/lib"
        ];

        meta = {
          description = "Luke Smith's dmenu build, as used by LARBS";
          homepage = "https://github.com/LukeSmithxyz/dmenu";
          license = lib.licenses.mit;
          platforms = lib.platforms.linux;
          mainProgram = "dmenu";
        };
      };

      # ---- dwmblocks: the status bar -----------------------------------
      larbs-dwmblocks = prev.stdenv.mkDerivation {
        pname = "larbs-dwmblocks";
        version = "0-unstable-larbs";

        src = prev.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "dwmblocks";
          rev = "1c9744ac7ded4fff8171169bc0b9736f3acd4cfe";
          hash = "sha256-gT2PXaQ0VdqlA77jpoXBjuFM5UTuGiIZ5eYzXFVm9TU=";
        };

        buildInputs = [ prev.libx11 ];
        makeFlags = [ "PREFIX=$(out)" "CC=cc" ];

        meta = {
          description = "Modular status bar for dwm, LARBS configuration";
          homepage = "https://github.com/LukeSmithxyz/dwmblocks";
          license = lib.licenses.isc;
          platforms = lib.platforms.linux;
          mainProgram = "dwmblocks";
        };
      };

      # ---- surf: read this before enabling ------------------------------
      # You asked for surf, and it is deliberately NOT installed. Two real
      # problems, not precautionary flags:
      #
      #   1. nixpkgs marks surf 2.1 broken. WebKitGTK removed the XEmbed
      #      support surf uses to embed its web view, so it dies with a
      #      BadWindow X error.
      #   2. It pulls in libsoup 2.74.3, which nixpkgs refuses to build
      #      because of known CVEs in that HTTP stack.
      #
      # Accepting a vulnerable HTTP library for a web browser is the worst
      # possible place to do it, so Super+Shift+c is bound to `vimb` instead
      # — same minimal, vim-keys, WebKitGTK idea, but maintained.
      #
      # To use surf anyway: uncomment the override below, uncomment `surf` in
      # the browser list in section 15, add "libsoup-2.74.3" to
      # nixpkgs.config.permittedInsecurePackages in section 3, and change
      # "vimb" to "surf" in `larbsExtraKeys` above.
      #
      # surf = prev.surf.overrideAttrs (old: {
      #   meta = old.meta // { broken = false; };
      # });

      # ---- the voidrice helper scripts ---------------------------------
      # Every keybinding above that names something like `sysact`, `lfub`,
      # `maimpick`, `mounter` or `dmenuunicode` resolves to a script here.
      # Without this package roughly a third of the LARBS bindings are dead.
      larbs-scripts = prev.stdenv.mkDerivation {
        pname = "larbs-scripts";
        version = "0-unstable-2026";

        src = prev.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "voidrice";
          rev = "ad944910efb2fd3086255767632ec8f0e8f5c06d";
          hash = "sha256-qu0nK4aWYjMSheA4tUO/C5mdmdyQRMEvLM63ObepZns=";
        };

        dontBuild = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $out/share/larbs
          cp -r .local/bin/. $out/bin/
          cp -r .local/share/larbs/. $out/share/larbs/ 2>/dev/null || true

          # The dotfile tree is kept whole so section 14 can seed from it.
          mkdir -p $out/share/larbs-dotfiles
          cp -r .config $out/share/larbs-dotfiles/config

          # st reads `alpha` from Xresources at startup, and that wins over
          # the value compiled into the binary. Keep the two in step so the
          # stAlpha setting in section 0 is actually what you see.
          chmod -R +w $out/share/larbs-dotfiles
          substituteInPlace $out/share/larbs-dotfiles/config/x11/xresources \
            --replace-fail '*.alpha: 0.8' '*.alpha: ${stAlpha}'
          for f in .zprofile .xprofile; do
            [ -e "$f" ] && cp "$f" $out/share/larbs-dotfiles/ || true
          done

          chmod -R +w $out/bin
          # /usr/bin/sh does not exist on NixOS; /bin/sh does.
          find $out/bin -type f -exec sed -i '1s|^#!/usr/bin/sh|#!/bin/sh|' {} +
          patchShebangs $out/bin

          runHook postInstall
        '';

        meta = {
          description = "Helper scripts from Luke Smith's voidrice, used by the LARBS keybindings";
          homepage = "https://github.com/LukeSmithxyz/voidrice";
          license = lib.licenses.gpl3Only;
          platforms = lib.platforms.linux;
        };
      };
    })
  ];

  # ══════════════════════════════════════════════════════════════════════════
  #  3 · NIX ITSELF
  # ══════════════════════════════════════════════════════════════════════════
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" username ];
  };

  # Keep the disk from filling up with old generations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Needed for a handful of firmware blobs and virtio-win. Everything this
  # config installs by name is free software.
  nixpkgs.config.allowUnfree = true;

  # Deliberately empty. Enabling surf (section 2) needs "libsoup-2.74.3"
  # here — read the note there first, it is a browser running on an HTTP
  # library with published CVEs.
  nixpkgs.config.permittedInsecurePackages = [ ];

  # ══════════════════════════════════════════════════════════════════════════
  #  4 · BOOT — read this if the rebuild is failing
  #
  #  ── 0. "No space left on device" / "mkdir /boot/grub" ─────────────────
  #  /boot is full. It is almost never actually about GRUB — NixOS keeps a
  #  kernel and an initrd in /boot for EVERY generation in the boot menu, at
  #  100-150M each, and EFI partitions are often only 512M (100M on laptops
  #  that shipped with Windows). `bootGenerationLimit` in section 0 is now 3
  #  instead of 10, which is the durable fix. To dig out right now:
  #
  #      df -h /boot                     # how bad is it
  #      du -sh /boot/* | sort -h        # what is eating it
  #
  #      # 1. Drop old generations. This is what frees the kernels.
  #      sudo nix-collect-garbage -d
  #
  #      # 2. Re-run the CURRENTLY BOOTED bootloader so it prunes /boot
  #      #    entries for the generations you just deleted. Uses the
  #      #    bootloader that already works, so it cannot strand you.
  #      sudo /run/current-system/bin/switch-to-configuration boot
  #
  #      df -h /boot                     # should have room now
  #      sudo nixos-rebuild switch
  #
  #  Do NOT hand-delete /boot/loader or /boot/EFI to make room before the
  #  new bootloader is installed — if the install then fails you have no
  #  bootloader at all and the machine will not come back up. Free space via
  #  garbage collection first, always.
  #
  #  Old systemd-boot files are not cleaned up when you move to GRUB. Once
  #  you have successfully booted via GRUB, and only then, /boot/loader and
  #  /boot/EFI/systemd are dead weight and safe to remove.
  #
  #  If /boot is under ~300M even when empty, it is genuinely too small for
  #  NixOS. Set bootGenerationLimit = 1, or resize the ESP.
  #
  #  ── 1. UEFI vs BIOS ───────────────────────────────────────────────────
  #      [ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
  #  Set `useUEFI` in section 0 to match.
  #
  #  ── 2. WHERE IS THE ESP? ──────────────────────────────────────────────
  #      lsblk -f        # the small vfat/FAT32 partition
  #  Set `espMountPoint`. A mismatch here is the classic
  #  "installing systemd-boot failed" / "not a FAT filesystem" error.
  #
  #  ── 3. EFI VARIABLE WRITES ────────────────────────────────────────────
  #  If it fails writing efivars, set `touchEfiVars = false` in section 0.
  #
  #  Whatever the error, `nixos-rebuild switch 2>&1 | tail -30` shows the
  #  real cause — NixOS prints a lot before the useful line.
  #
  #  ── 4. THEMES ─────────────────────────────────────────────────────────
  #  systemd-boot cannot be themed at all. If you want a boot theme you must
  #  be on GRUB — set `useGrub = true` in section 0 (it already is).
  # ══════════════════════════════════════════════════════════════════════════
  boot.loader = lib.mkMerge [
    # EFI settings apply to both bootloaders, but only on UEFI machines —
    # setting them on a BIOS box trips a NixOS assertion.
    (lib.mkIf useUEFI {
      efi.canTouchEfiVariables = touchEfiVars;
      efi.efiSysMountPoint = espMountPoint;
    })

    (lib.mkIf useGrub {
      grub = {
        enable = true;
        configurationLimit = bootGenerationLimit;

        # On UEFI, GRUB is installed into the ESP and "device" must be the
        # literal string "nodev" — there is no MBR to write to. On BIOS it
        # is the actual disk.
        efiSupport = useUEFI;
        device = if useUEFI then "nodev" else grubDevice;

        # The theme, plus the graphics mode it gets drawn into.
        theme = grubTheme;
        gfxmodeEfi = grubResolution;
        gfxmodeBios = grubResolution;

        # Uncomment if you dual-boot and want Windows/other distros detected.
        # useOSProber = true;
      };
    })

    (lib.mkIf (!useGrub) {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = bootGenerationLimit;
    })
  ];

  # systemd-boot is UEFI-only; catch the impossible combination at build time
  # with a clear message rather than a confusing failure at install time.
  assertions = [
    {
      assertion = useGrub || useUEFI;
      message = ''
        systemd-boot requires UEFI firmware. This machine is configured as
        BIOS (useUEFI = false), so set useGrub = true in section 0.
      '';
    }
  ];

  # Quieter boot, in keeping with the rest of the setup.
  boot.kernelParams = [ "quiet" "udev.log_level=3" ];

  # Deliberately NOT forcing kvm-intel/kvm-amd here. Listing both — which an
  # earlier version of this file did — guarantees one of them fails to load
  # on any real machine and fills your boot log with errors. The kernel
  # autoloads the correct one from the CPU ID, so there is nothing to do.
  #
  # These modprobe options only take effect if the matching module is loaded,
  # so having both lines is harmless on either vendor.
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_amd nested=1
  '';

  # ══════════════════════════════════════════════════════════════════════════
  #  5 · NETWORKING — wifi that works on a laptop out of the box
  #  Super + Shift + w opens nmtui, which is how you join a network.
  # ══════════════════════════════════════════════════════════════════════════
  networking.hostName = hostName;
  networking.networkmanager.enable = true;

  # THE thing that makes laptop wifi work. Practically every Intel, Broadcom,
  # Realtek and Atheros wifi chip needs a binary firmware blob, and without
  # this the card simply does not appear — no error, no interface, nothing.
  # It is off by default in NixOS because the blobs are redistributable but
  # not open source.
  hardware.enableRedistributableFirmware = true;

  # Note: do NOT set `networking.wireless.enable = false` here to "avoid a
  # conflict with wpa_supplicant". Modern NetworkManager switches wpa_supplicant
  # on deliberately and drives it over DBus, so forcing it off breaks wifi
  # rather than fixing it. Leave the radio to NetworkManager.

  # Waits for a network at every boot and fails the unit when there isn't one
  # yet — which on a laptop that roams is most boots. It turns a fine boot
  # into a red "FAILED" line and a 90-second hang. Nothing here needs it.
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # ══════════════════════════════════════════════════════════════════════════
  #  6 · LOCALE, TIME, CONSOLE
  # ══════════════════════════════════════════════════════════════════════════
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    earlySetup = true;
    keyMap = "us";
  };

  # ══════════════════════════════════════════════════════════════════════════
  #  7 · THE USER
  #  Set the password after the first rebuild:  sudo passwd samadams
  # ══════════════════════════════════════════════════════════════════════════
  users.users.${username} = {
    isNormalUser = true;
    uid = userUid;
    description = fullName;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"           # sudo
      "networkmanager"  # nmtui without a password prompt
      "video"           # backlight control
      "audio"
      "input"
      "libvirtd"        # QEMU/KVM via virt-manager
      "kvm"
      "storage"
      "tss"             # TPM, for swtpm-backed VMs
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  # ══════════════════════════════════════════════════════════════════════════
  #  8 · GRAPHICS — X11 and dwm
  # ══════════════════════════════════════════════════════════════════════════
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      # LARBS makes Caps Lock dual-role: HELD it is another Super, TAPPED it
      # is Escape. The xkb half is here; the tap-for-Escape half needs xcape,
      # which `remaps` starts in extraSessionCommands below.
      # (An earlier version of this file used plain "caps:escape", which lost
      # the extra Super and contradicted what Super+F1 tells you.)
      options = "caps:super,altwin:menu_win";
    };

    windowManager.dwm = {
      enable = true;
      package = pkgs.larbs-dwm;

      # Run before dwm starts. This is the NixOS equivalent of LARBS's
      # ~/.config/x11/xinitrc.
      extraSessionCommands = ''
        # Java apps misbehave under non-reparenting WMs without this.
        export _JAVA_AWT_WM_NONREPARENTING=1

        # Load colours/settings; dwm re-reads these on Super+F5.
        [ -f "$HOME/.config/x11/xresources" ] && \
          ${pkgs.xrdb}/bin/xrdb -merge "$HOME/.config/x11/xresources"

        # The status bar. Super+F5 restarts it.
        ${pkgs.larbs-dwmblocks}/bin/dwmblocks &

        # Compositing. st's transparency (stAlpha, section 0) does nothing
        # without a compositor running, so this has to come up before dwm.
        ${pkgs.xcompmgr}/bin/xcompmgr &
        ${pkgs.unclutter-xfixes}/bin/unclutter &

        # Notifications, used by many of the LARBS scripts.
        ${pkgs.dunst}/bin/dunst &

        # Music daemon. Runs here rather than as a system service so it comes
        # up after PipeWire and can actually reach it — see section 10.
        ${pkgs.mpd}/bin/mpd &

        # ── WALLPAPER ────────────────────────────────────────────────────
        # LARBS tracks the current wallpaper as a symlink at
        # ~/.local/share/bg, and `setbg` reads it. On a fresh install that
        # link does not exist, `setbg` exits before reaching xwallpaper, and
        # you get a grey X root window — which is why this did not load on
        # boot before. Point it at the bundled default the first time.
        bg="$HOME/.local/share/bg"
        if [ ! -e "$bg" ]; then
          mkdir -p "$HOME/.local/share"
          ln -sfn ${defaultWallpaper} "$bg"
        fi
        ${pkgs.xwallpaper}/bin/xwallpaper --zoom "$bg" &

        # Caps Lock held = Super, tapped = Escape; Menu = right Super. This
        # is what the Super+F1 manual describes, and it needs xcape running,
        # not just an xkb option. Also sets the faster key repeat.
        ${pkgs.larbs-scripts}/bin/remaps &

        true
      '';
    };

  };

  # Sensible touchpad behaviour on laptops.
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = false;
    touchpad.tapping = true;
  };

  # A minimal TUI login manager, in keeping with the rest of the system.
  # Prefer the pure LARBS way (log in on a tty, then run `startx`)? Swap the
  # two lines below for:  services.xserver.displayManager.startx.enable = true;
  services.displayManager.ly.enable = true;

  hardware.graphics.enable = true;

  # ══════════════════════════════════════════════════════════════════════════
  #  9 · FONTS
  #  dwm and st ask for "monospace"; the mapping below decides what that is.
  # ══════════════════════════════════════════════════════════════════════════
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono   # monospace with powerline/nerd glyphs
      noto-fonts
      noto-fonts-color-emoji      # dwm's second font is NotoColorEmoji
      libertinus                  # LARBS's serif/sans
      font-awesome                # dwmblocks status icons
    ];

    enableDefaultPackages = true;

    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font Mono" "Noto Sans Mono" ];
      sansSerif = [ "Libertinus Sans" "Noto Sans" ];
      serif     = [ "Libertinus Serif" "Noto Serif" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  # ══════════════════════════════════════════════════════════════════════════
  # 10 · AUDIO — PipeWire
  #  The volume keybindings drive `wpctl`, which comes from WirePlumber.
  # ══════════════════════════════════════════════════════════════════════════
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # mpd backs Super+p, Super+comma/period and the ncmpcpp binding.
  # mpd is deliberately NOT run as a system service. A system-level mpd starts
  # at boot, before anyone has logged in, so /run/user/<uid> does not exist
  # yet and it cannot reach the user's PipeWire socket — the unit just fails,
  # red, on every single boot. If you saw errors after a rebuild, this was one
  # of them.
  #
  # LARBS starts mpd from the X session instead, and the seeded
  # ~/.config/mpd/mpd.conf already declares the PipeWire output plus the fifo
  # that ncmpcpp's visualiser reads. Section 8 autostarts it; the directories
  # it expects are created below so it never fails on a fresh home.
  systemd.tmpfiles.rules = [
    "d /home/${username}/Music 0755 ${username} users -"
    "d /home/${username}/.config/mpd 0755 ${username} users -"
    "d /home/${username}/.config/mpd/playlists 0755 ${username} users -"
  ];

  # ══════════════════════════════════════════════════════════════════════════
  # 11 · VIRTUALISATION — QEMU / KVM
  #  Super + Shift + s opens virt-manager.
  # ══════════════════════════════════════════════════════════════════════════
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;          # emulated TPM, needed for Windows 11 guests
      # UEFI firmware for guests ships with QEMU now, so there is nothing
      # further to wire up here — just pick OVMF as the firmware in
      # virt-manager when you create the VM.
    };
  };

  programs.virt-manager.enable = true;

  # USB pass-through from the host into a running guest.
  virtualisation.spiceUSBRedirection.enable = true;

  # ══════════════════════════════════════════════════════════════════════════
  # 12 · TOR
  #  Super + Shift + Tab opens Tor Browser; `torsocks <cmd>` routes anything
  #  else through the daemon below.
  #
  #  Note that LARBS's Super+F6 `torwrap` has nothing to do with Tor — it is
  #  a *torrent* wrapper (transmission + stig). Same three letters, different
  #  program. Both are wired up; they are just unrelated.
  # ══════════════════════════════════════════════════════════════════════════
  services.tor = {
    enable = true;
    client.enable = true;           # SOCKS proxy on 127.0.0.1:9050
  };
  # The `torsocks` wrapper itself is installed in section 15.

  # ══════════════════════════════════════════════════════════════════════════
  # 13 · SHELL, EDITOR, MULTIPLEXER
  # ══════════════════════════════════════════════════════════════════════════

  # ---- zsh -----------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 100000;

    shellAliases = {
      ls = "ls -hN --color=auto --group-directories-first";
      ll = "ls -lahN --color=auto --group-directories-first";
      grep = "grep --color=auto";
      diff = "diff --color=auto";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -vI";
      mkd = "mkdir -pv";
      ffa = "fastfetch";
      v = "nvim";
      lf = "lfub";                        # the ueberzug image-preview wrapper
      # Handy NixOS shortcuts
      nrs = "sudo nixos-rebuild switch";
      nrt = "sudo nixos-rebuild test";
      cfn = "sudo -E nvim /etc/nixos/configuration.nix";
    };

    interactiveShellInit = ''
      # vi keys on the command line, as in LARBS.
      bindkey -v
      export KEYTIMEOUT=1

      # Ctrl+o — open lf, and cd to wherever you left off.
      lfcd () {
        tmp="$(mktemp -uq)"
        trap 'rm -f "$tmp" >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
        lfub -last-dir-path="$tmp" "$@"
        if [ -f "$tmp" ]; then
          dir="$(cat "$tmp")"
          [ -d "$dir" ] && [ "$dir" != "$PWD" ] && cd "$dir"
        fi
      }
      bindkey -s '^o' '^ulfcd\n'

      # Ctrl+f — fuzzy-find a file below here and cd to its directory.
      bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

      # Ctrl+a — a quick calculator.
      bindkey -s '^a' '^ubc -lq\n'

      # Ctrl+l clears the screen even in vi normal mode.
      bindkey '^L' clear-screen

      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
  };

  users.defaultUserShell = pkgs.zsh;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "st";
    BROWSER = "firefox";
    READER = "zathura";
    FILE = "lfub";
    # `mounter` and `unmounter` (Super+F9 / Super+F10) call `sudo -A`, which
    # does nothing at all unless SUDO_ASKPASS points at a password prompt.
    # Upstream sets this in ~/.zprofile to a path under ~/.local/bin; here the
    # scripts live in the store, so point at them directly.
    SUDO_ASKPASS = "${pkgs.larbs-scripts}/bin/dmenupass";
    # Keep $HOME tidy, the way LARBS does.
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # ---- neovim --------------------------------------------------------------
  # Answering the "+y request directly: the clipboard register is wired to the
  # X11 CLIPBOARD selection, `unnamedplus` makes plain y/p use it by default,
  # and the explicit <leader>y / <leader>p maps below are the literal "+y and
  # "+p commands if you would rather be explicit about it. `,` is the leader.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      customRC = ''
        let mapleader = ","

        " ── clipboard ────────────────────────────────────────────────────
        " Every yank/delete/put also uses the system CLIPBOARD ("+ register).
        set clipboard+=unnamedplus

        " …and the same thing spelled out, for when you want to be explicit:
        nnoremap <leader>y "+y
        vnoremap <leader>y "+y
        nnoremap <leader>Y "+yg_
        nnoremap <leader>yy "+yy
        nnoremap <leader>p "+p
        vnoremap <leader>p "+p
        nnoremap <leader>P "+P
        nnoremap <leader>d "+d
        vnoremap <leader>d "+d
        " Yank the whole buffer to the clipboard.
        nnoremap <leader>ya :%y+<CR>

        " ── basics ───────────────────────────────────────────────────────
        set title
        set mouse=a
        set nohlsearch
        set incsearch
        set ignorecase smartcase
        set number relativenumber
        set encoding=utf-8
        set noshowmode
        set scrolloff=5
        set splitbelow splitright
        set expandtab shiftwidth=2 tabstop=2 softtabstop=2
        set undofile
        syntax on
        filetype plugin indent on
        colorscheme habamax

        " Do not clobber the yank register when changing text.
        nnoremap c "_c

        " Autocompletion menu behaviour.
        set wildmode=longest,list,full

        " Never continue a comment onto the next line automatically.
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

        " Apply a dot-command across a visual block.
        vnoremap . :normal .<CR>

        " ── navigation ───────────────────────────────────────────────────
        map <C-h> <C-w>h
        map <C-j> <C-w>j
        map <C-k> <C-w>k
        map <C-l> <C-w>l

        " ── LARBS conventions ────────────────────────────────────────────
        " ,, jumps to the next <++> placeholder and eats it.
        map ,, :keepp /<++><CR>ca<
        imap ,, <esc>:keepp /<++><CR>ca<

        " Spell check ('o' for orthography) and distraction-free writing.
        map <leader>o :setlocal spell! spelllang=en_us<CR>
        map <leader>f :Goyo \| set linebreak<CR>
        map <leader>n :NERDTreeToggle<CR>

        " Strip trailing whitespace on save.
        autocmd BufWritePre * let currPos = getpos(".") |
          \ %s/\s\+$//e |
          \ call cursor(currPos[1], currPos[2])
      '';

      packages.larbs = with pkgs.vimPlugins; {
        start = [
          vim-surround      # cs"' etc.
          vim-commentary    # gcc / gc{motion}
          nerdtree          # <leader>n
          goyo-vim          # <leader>f
          vim-airline       # statusline
          vim-css-color     # inline colour previews
          vimwiki           # Super+n opens the index
          vim-fugitive      # :Git
          vim-nix           # syntax for this very file
        ];
      };
    };
  };

  # ---- tmux ----------------------------------------------------------------
  # Prefix is Ctrl+a. Copy-mode uses vi keys and yanks into the same X11
  # CLIPBOARD that nvim's "+ register uses, so the two share a clipboard.
  programs.tmux = {
    enable = true;
    shortcut = "a";                 # prefix = Ctrl+a
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;                 # no delay on Escape, which vi mode needs
    historyLimit = 50000;
    terminal = "tmux-256color";
    aggressiveResize = true;
    customPaneNavigationAndResize = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
    ];

    extraConfig = ''
      # ── general ───────────────────────────────────────────────────────
      set -g mouse on
      set -g focus-events on
      set -g renumber-windows on
      set -ga terminal-overrides ",*256col*:Tc,st-256color:Tc"

      # ── splits, in the same directory, with vim-ish keys ──────────────
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Ctrl+a Ctrl+a jumps to the last window.
      bind C-a last-window

      # Reload this config.
      bind r source-file /etc/tmux.conf \; display-message "tmux.conf reloaded"

      # ── copy mode: v to select, y to yank to the X11 clipboard ────────
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${pkgs.xclip}/bin/xclip -selection clipboard -i"
      bind -T copy-mode-vi Escape send-keys -X cancel
      bind P paste-buffer

      # ── a status line that matches dwm's ──────────────────────────────
      set -g status-style "bg=#222222,fg=#bbbbbb"
      set -g status-left "#[bg=#005577,fg=#eeeeee,bold] #S #[default] "
      set -g status-right "#[fg=#bbbbbb]#H #[bg=#005577,fg=#eeeeee,bold] %Y-%m-%d %H:%M "
      set -g status-left-length 30
      set -g status-right-length 60
      setw -g window-status-current-style "bg=#005577,fg=#eeeeee,bold"
      setw -g window-status-current-format " #I:#W "
      setw -g window-status-format " #I:#W "
      set -g pane-active-border-style "fg=#005577"
      set -g pane-border-style "fg=#444444"
    '';
  };

  # ══════════════════════════════════════════════════════════════════════════
  # 14 · CONFIG FILES
  #
  #  neovim and zsh are configured declaratively above, so Luke's versions of
  #  those two are deliberately NOT seeded — a wrapped neovim ignores
  #  ~/.config/nvim anyway, and two zshrc files fight each other. Everything
  #  else from voidrice (lf, dunst, mpv, zathura, ncmpcpp, X resources, the
  #  shell aliasrc and bookmarks) is copied into $HOME on first activation.
  #
  #  `cp -rn` never clobbers: once a file exists, it is yours. Delete the
  #  stamp file named below to seed again after an upstream bump.
  # ══════════════════════════════════════════════════════════════════════════
  system.activationScripts.larbsDotfiles = lib.mkIf seedLarbsDotfiles {
    deps = [ "users" ];
    text = ''
      home="/home/${username}"
      stamp="$home/.local/share/larbs/.seeded"

      if [ -d "$home" ] && [ ! -e "$stamp" ]; then
        echo "seeding LARBS dotfiles into $home"
        mkdir -p "$home/.config" "$home/.local/share/larbs"

        for d in ${pkgs.larbs-scripts}/share/larbs-dotfiles/config/*; do
          name="$(basename "$d")"
          # Managed declaratively in section 13 — skip.
          case "$name" in nvim|zsh) continue ;; esac
          cp -rn "$d" "$home/.config/" 2>/dev/null || true
        done

        cp -rn ${pkgs.larbs-scripts}/share/larbs/. "$home/.local/share/larbs/" 2>/dev/null || true

        chmod -R u+w "$home/.config" "$home/.local" 2>/dev/null || true
        chown -R ${username}:users "$home/.config" "$home/.local" 2>/dev/null || true
        touch "$stamp"
        chown ${username}:users "$stamp" 2>/dev/null || true
      fi
    '';
  };

  # htop reads /etc/htoprc when the user has no ~/.config/htop/htoprc yet.
  # Super + Shift + r opens it.
  environment.etc."htoprc".text = ''
    fields=0 48 17 18 38 39 40 2 46 47 49 1
    hide_kernel_threads=1
    hide_userland_threads=1
    shadow_other_users=0
    show_thread_names=0
    show_program_path=0
    highlight_base_name=1
    highlight_megabytes=1
    highlight_threads=1
    highlight_changes=0
    find_comm_in_cmdline=1
    strip_exe_from_cmdline=1
    tree_view=1
    header_margin=1
    detailed_cpu_time=0
    cpu_count_from_one=1
    show_cpu_usage=1
    show_cpu_frequency=0
    update_process_names=0
    account_guest_in_cpu_meter=0
    color_scheme=0
    enable_mouse=1
    delay=15
    left_meters=LeftCPUs2 Memory Swap
    left_meter_modes=1 1 1
    right_meters=RightCPUs2 Tasks LoadAverage Uptime
    right_meter_modes=1 2 2 2
  '';

  # fastfetch picks this up from XDG_CONFIG_DIRS (/etc/xdg) when the user has
  # no config of their own. Super + Shift + Escape runs it.
  environment.etc."xdg/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "type": "small",
        "padding": { "top": 1, "right": 3 }
      },
      "display": {
        "separator": "  ",
        "color": { "keys": "blue", "title": "cyan" }
      },
      "modules": [
        "title",
        "separator",
        { "type": "os", "key": "  os" },
        { "type": "kernel", "key": "  kernel" },
        { "type": "uptime", "key": "  uptime" },
        { "type": "packages", "key": "  packages" },
        { "type": "shell", "key": "  shell" },
        { "type": "wm", "key": "  wm" },
        { "type": "terminal", "key": "  term" },
        { "type": "cpu", "key": "  cpu" },
        { "type": "gpu", "key": "  gpu" },
        { "type": "memory", "key": "  memory" },
        { "type": "disk", "key": "  disk" },
        "break",
        "colors"
      ]
    }
  '';

  # ══════════════════════════════════════════════════════════════════════════
  # 15 · PROGRAMS
  # ══════════════════════════════════════════════════════════════════════════
  programs.firefox.enable = true;   # Super + w
  programs.dconf.enable = true;     # GTK apps need this to read their settings
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  environment.systemPackages = with pkgs; [
    # ---- the suckless stack (section 2) ---------------------------------
    larbs-st                 # Super+Return
    larbs-dmenu              # Super+d
    larbs-dwmblocks          # the status bar
    larbs-scripts            # sysact, lfub, maimpick, mounter, dmenuunicode, …

    # ---- browsers -------------------------------------------------------
    vimb                     # Super+Shift+c — minimal vim-keys browser
    # surf                   # see the long note in section 2 before enabling
    tor-browser              # Super+Shift+Tab
    torsocks                 # run anything through Tor
    lynx                     # terminal browser; lf uses it for HTML previews

    # ---- terminal life --------------------------------------------------
    htop                     # Super+Shift+r
    fastfetch                # Super+Shift+Escape
    lf                       # Super+r (the `lfub` wrapper adds image previews)
    ueberzugpp               # image previews inside lf
    fzf                      # Ctrl+f in zsh
    bat ripgrep fd eza zoxide starship
    tree jq unzip zip atool
    wget curl git gnumake
    bc                       # Super+apostrophe calculator, Ctrl+a in zsh
    trash-cli
    psmisc                   # `killall`, which several bindings below need:
                             #   Super+F3 displayselect, Super+F7 td-toggle,
                             #   Super+F12 remaps, Super+ScrollLock screenkey,
                             #   and dwm's own bar restart on Super+F5.
                             # NixOS's base system ships procps but not psmisc.
    pulseaudio               # for `pactl`, which the mic-mute media key calls.
                             # PipeWire is still the sound server (section 10);
                             # this is only the client tool.
    ts                       # task-spooler, used by LARBS's queue scripts

    # ---- media ----------------------------------------------------------
    mpv                      # video
    ani-cli                  # Super+Shift+b — streams anime, needs mpv + fzf
    yt-dlp                   # ani-cli and LARBS's qndl both use this
    ffmpeg
    nsxiv                    # image viewer
    zathura                  # Super+F1 renders the dwm manual into this
    mpd                      # started from the X session, see sections 8 & 10
    mpc                      # the music keybindings shell out to this
    ncmpcpp                  # Super+m
    pulsemixer               # Super+F4
    pavucontrol
    playerctl
    mediainfo

    # ---- mail, news, chat, notes ---------------------------------------
    neomutt                  # Super+e
    mutt-wizard              # provides `mailsync`, which Super+F8 calls
    isync msmtp              # mutt-wizard syncs and sends through these
    pass                     # provides `passmenu`, which Super+Shift+d calls
    abook                    # Super+Shift+e
    newsboat                 # Super+Shift+n
    profanity                # Super+c
    calcurse
    sc-im

    # ---- torrents (Super+F6 `torwrap`, Super+F7 `td-toggle`) ------------
    # Nothing to do with Tor, despite the script name — see section 12.
    # torwrap bails out immediately unless both of these are present.
    transmission_4           # provides transmission-daemon
    stig                     # the TUI client torwrap actually opens

    # ---- X11 utilities the keybindings depend on ------------------------
    xinit
    xrdb                # Super+F5
    xprop
    xwininfo
    xset
    setxkbmap
    xbacklight
    xrandr                   # displayselect (Super+F3) and dmenurecord drive this
    slop                     # region selection for dmenurecord (Super+Print)
    xclip                    # the "+ register in nvim and tmux's y binding
    xdotool                  # Super+Insert snippet expansion
    xcape                    # Super+F12 remaps
    xwallpaper               # setbg
    xcompmgr
    unclutter-xfixes
    maim                     # PrintScreen
    slock                    # screen locker
    dunst libnotify          # notifications
    arandr                   # Super+F3 companion
    screenkey                # Super+ScrollLock
    tesseract                # OCR option inside maimpick
    wmctrl
    groff                    # renders larbs.mom for Super+F1

    # The XF86Sleep media key runs `sudo -A zzz`, which is a Void Linux
    # script that does not exist here. This is the NixOS equivalent, so the
    # key does something instead of failing silently.
    (writeShellScriptBin "zzz" ''exec systemctl suspend "$@"'')

    # ---- virtualisation --------------------------------------------------
    qemu                     # Super+Shift+s opens virt-manager on top of this
    qemu_kvm
    OVMFFull
    virtiofsd
    spice-gtk
    virtio-win               # virtio drivers to hand to Windows guests

    # ---- theming ---------------------------------------------------------
    gruvbox-gtk-theme        # LARBS uses arc-gruvbox; this is the closest
    papirus-icon-theme
    adwaita-icon-theme
    lxappearance

    # ---- system ----------------------------------------------------------
    networkmanagerapplet     # nmtui is the keybinding, this is the tray applet
    pciutils usbutils lm_sensors
    ntfs3g exfatprogs dosfstools simple-mtpfs
    poppler-utils            # lf's PDF previews
    man-pages man-pages-posix
    xdg-utils

    # ---- added by you ----------------------------------------------------
    feh                      # image viewer; also a common wallpaper setter.
                             # Note LARBS's `setbg` uses xwallpaper (already
                             # installed in the X11 block above), so feh is
                             # here as a viewer rather than as the wallpaper
                             # mechanism — `feh --bg-scale <img>` still works
                             # if you prefer it.
    python3
    sherlock                 # OSINT: hunt a username across social networks
  ];

  # st ships its own terminfo; make sure it lands in the system path so that
  # TERM=st-256color resolves for every user.
  environment.pathsToLink = [ "/share/terminfo" ];
  environment.enableAllTerminfo = true;

  # ══════════════════════════════════════════════════════════════════════════
  # 16 · SERVICES
  # ══════════════════════════════════════════════════════════════════════════
  services.dbus.enable = true;
  services.gvfs.enable = true;                    # LARBS's `mounter` uses this
  services.udisks2.enable = true;                 # …and this
  services.gnome.gnome-keyring.enable = true;
  services.printing.enable = true;
  services.openssh.enable = false;

  # Trim SSDs weekly.
  services.fstrim.enable = true;

  # A polkit agent, so graphical privilege prompts actually appear.
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  security.polkit.enable = true;

  # ══════════════════════════════════════════════════════════════════════════
  # 17 · STATE VERSION
  #  This records the NixOS release the system was first installed with so
  #  that stateful defaults (database layouts and the like) stay put. Leave
  #  it alone when you upgrade; it is not the version you are running.
  # ══════════════════════════════════════════════════════════════════════════
  system.stateVersion = "26.05";
}
