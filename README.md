# samadams — NixOS + LARBS

A single-file NixOS configuration that reproduces [LARBS](https://larbs.xyz)
(Luke Smith's Auto-Rice Bootstrapping Scripts) declaratively: the same suckless
desktop, the same programs, and the same keybindings — but built by Nix instead
of an Arch install script.

Everything lives in [`configuration.nix`](./configuration.nix), split into
numbered sections with dividers. The full keybinding reference is a comment
block at the top of that file.

## Install

```sh
# 1. Generate the machine-specific hardware config (configuration.nix imports it)
sudo nixos-generate-config

# 2. Put this config in place
sudo cp configuration.nix /etc/nixos/configuration.nix

# 3. Build
sudo nixos-rebuild switch

# 4. Give the account a password, then log in
sudo passwd samadams
```

Targets NixOS **26.05**. To rename the account or host, edit section 0 — the
rest of the file reads from those bindings.

## What you get

| | |
|---|---|
| Window manager | dwm — Luke's build, pinned revision, with vanitygaps, scratchpads and window swallowing |
| Terminal | st — scrollback, ligatures, URL picker |
| Launcher / bar | dmenu, dwmblocks |
| Editor | neovim, with the system clipboard wired up (see below) |
| Multiplexer | tmux — `Ctrl+a` prefix, vi copy-mode yanking to the same X clipboard |
| Shell | zsh — vi keys, LARBS's `Ctrl+o` / `Ctrl+f` / `Ctrl+a` bindings, starship, zoxide |
| Browsers | Firefox, Tor Browser, vimb, lynx |
| Monitors | htop, fastfetch |
| Virtualisation | QEMU/KVM via libvirt + virt-manager, with swtpm for Windows guests |
| Privacy | Tor daemon and SOCKS proxy on `127.0.0.1:9050` |
| Media | mpv, ani-cli, ncmpcpp/mpd, nsxiv, zathura, yt-dlp |
| Mail / news / chat | neomutt + mutt-wizard, newsboat, abook, profanity |

Sections 2 and 15 list which package backs which keybinding.

## Answering "vim with `"+y`"

Section 13 sets `clipboard+=unnamedplus`, so plain `y` and `p` already use the
X11 CLIPBOARD selection. The explicit form is mapped too, with `,` as leader:

| Keys | Does |
|---|---|
| `,y` | yank to `"+` (normal and visual) |
| `,Y` | yank to end of line into `"+` |
| `,yy` | yank the line into `"+` |
| `,p` / `,P` | put from `"+` |
| `,d` | delete into `"+` |
| `,ya` | `:%y+` — yank the whole buffer |

tmux copy-mode `y` pipes through `xclip -selection clipboard`, so nvim, tmux and
every X app share one clipboard.

## Common knobs

All in section 0, at the top of `configuration.nix`:

| Setting | Default | What it does |
|---|---|---|
| `stAlpha` | `0.72` | Terminal transparency. Lower = more see-through. `Alt+a` / `Alt+s` adjust it live in a running terminal if you want to find your number first. |
| `useUEFI` | `true` | Set `false` on a BIOS/MBR machine. |
| `useGrub` | `true` | GRUB (themeable) vs systemd-boot (simpler, but **cannot** be themed). |
| `grubTheme` | `catppuccin-grub` | Boot menu theme. `sleek-grub-theme` is the other packaged option; `null` for plain. |
| `grubResolution` | `auto` | Boot menu graphics mode. Set an exact resolution if the menu looks wrong. |
| `seedLarbsDotfiles` | `true` | Whether to copy Luke's dotfiles into `$HOME` on first activation. |

Transparency needs a compositor, which section 8 starts (`xcompmgr`) before dwm.
Note that `stAlpha` has to be applied in two places — st reads `alpha` from
Xresources at startup and that silently overrides the compiled-in value. The
config patches both from the one setting; if your home was already seeded from
an earlier build, edit `~/.config/x11/xresources` too.

## If `nixos-rebuild switch` throws errors

Most first-build failures on a laptop are one of these:

1. **UEFI vs BIOS mismatch.** Run `[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS`
   and set `useUEFI` to match. This is the most common one by far.
   Then check where your EFI partition is (`lsblk -f`, it's the small FAT32 one)
   and set `espMountPoint` — `/boot` and `/boot/efi` are both common, and a
   mismatch gives you a "failed to install the boot loader" error.
2. **Wifi firmware.** `hardware.enableRedistributableFirmware` is on in section 5.
   Without it most Intel/Broadcom/Realtek cards do not appear at all — no error,
   just no interface.
3. **Failed units at boot rather than a build error.** `systemctl --failed`
   tells you which. Two known ones are already fixed here: mpd is no longer a
   system service (it started before PipeWire existed and failed every boot),
   and `NetworkManager-wait-online` is disabled (it fails whenever you boot out
   of range of a known network).

If something still fails, `journalctl -b -p err` is the fastest way to see what.

## Two things to know

**Dotfiles are seeded, not managed.** On first activation, Luke's configs for lf,
dunst, mpv, zathura, ncmpcpp and X resources are copied into `~/.config` with
`cp -rn`, so nothing you have written is ever overwritten. `nvim` and `zsh` are
deliberately skipped — those are configured declaratively in section 13, and a
wrapped neovim ignores `~/.config/nvim` anyway. To re-seed after bumping the
pinned revision, delete `~/.local/share/larbs/.seeded`. Set
`seedLarbsDotfiles = false` in section 0 to turn it off.

**surf is not installed, on purpose.** You asked for it, and it is one
uncomment away, but it has two real problems in nixpkgs 26.05: it is marked
broken because WebKitGTK dropped the XEmbed support surf relies on, and it drags
in libsoup 2.74.3, which is flagged for known CVEs. A web browser is the worst
place to accept a vulnerable HTTP stack, so `Super+Shift+c` opens `vimb`
instead — the same minimal, vim-keys, WebKitGTK idea on a maintained codebase.
Section 2 has the exact steps if you want surf anyway.

## Verification

The config evaluates against nixpkgs 26.05 with no errors and no deprecation
warnings, and all five from-source packages (dwm, st, dmenu, dwmblocks, and the
voidrice helper scripts) compile. The added keybindings were confirmed present
in the built `dwm` binary.

Every binding was then traced to the program it actually launches — including
the commands the LARBS helper scripts shell out to internally, which is where
most of the gaps were.

### Bindings that need setup before they do anything

These work, but only once you have configured the thing behind them:

| Binding | Needs |
|---|---|
| `Super+e`, `Super+F8` | a mail account — run `mw -a you@example.com` first |
| `Super+Shift+d` | an initialised `pass` store (`pass init <gpg-id>`) |
| `Super+c` | an XMPP account in profanity |
| `Super+m` and the music keys | music in `~/Music` (mpd is already running) |
| `Super+Insert` | a `~/.local/share/larbs/snippets` file you write yourself |

### Known dead

The touchpad-toggle media keys call `synclient`, from the old X synaptics
driver. This config uses libinput instead, so those keys do nothing. Use your
laptop's own touchpad toggle, or the libinput settings in section 8.
