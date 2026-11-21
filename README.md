<p align="center">
  <img src="vertical-terminal-icon.png" width="128" alt="Jat icon">
</p>

# Jat

Just Another Terminal is a macOS fork of [Ghostty](https://github.com/ghostty-org/ghostty) with a resizable vertical tab sidebar and inline suggestions from local zsh history.

- Press **⌘B** to hide or show the sidebar. Drag its divider to resize it.
- Use the title-bar arrows to move between adjacent tabs, or **+** to open a new one.
- In an interactive zsh session, type the start of a previous command. Press **Tab** to accept a visible suggestion. Press **Return** to run the command. Tab uses your regular completion when there’s no suggestion.

## Build on macOS

You’ll need Zig 0.17.0, Xcode with its Metal Toolchain, and gettext. With Xcode installed at its default path and Homebrew gettext on Apple silicon, run:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export PATH="$DEVELOPER_DIR/usr/bin:/opt/homebrew/opt/gettext/bin:$PATH"
zig build -Doptimize=ReleaseFast -Dxcframework-target=native
open "zig-out/Jat.app"
```

If gettext is installed somewhere else, add its `bin` directory to `PATH` instead.

## Configuration

Open the config from **Jat → Preferences**. Jat uses a separate configuration so it can run alongside Ghostty. Its config lives at `~/.config/vertical-terminal/config.ghostty` or `~/Library/Application Support/dev.royy.vertical-terminal/config.ghostty`.

Set `shell-integration-features = no-suggestions` to turn off history suggestions in new shells. See the [Ghostty documentation](https://ghostty.org/docs) for inherited terminal settings.

## Credits and license

Jat is an independent fork based on [Ghostty’s 1.4.0 development tree](https://github.com/ghostty-org/ghostty/commit/83fb95624b0439ee660c2679b43b38c8b63769cd). It retains Ghostty’s terminal engine, upstream history, and [MIT license](LICENSE). Thanks to Mitchell Hashimoto and the Ghostty contributors.
