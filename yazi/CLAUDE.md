# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Yazi file manager configuration directory. Yazi is a terminal file manager written in Rust. Configuration is done entirely via TOML files.

## Configuration Files

- **`yazi.toml`** — Main config: flavor selection, openers, file-open rules, manager display settings, and preview options.
- **`theme.toml`** — Theme overrides applied on top of the active flavor. Defines colors for manager, status bar, filetype highlighting, and the full icon set (dirs, files, extensions, conditions).
- **`flavors/noctalia.yazi/flavor.toml`** — The `noctalia` flavor: a complete color scheme covering all UI components (mgr, status, mode, input, tabs, cmp, tasks, which, spot, help, notify, filetype, icons).

## Key Design Decisions

- The active flavor is set in **two places** and must stay consistent:
  - `yazi.toml` → `[flavor] dark = "ococarbon"` (selects the flavor Yazi loads)
  - `theme.toml` → `[flavor] dark = "noctalia" light = "noctalia"` (overrides which flavor file is used)
- `theme.toml` overrides sit on top of the flavor — settings in `theme.toml` take precedence over `flavor.toml`.
- The default opener for text/config files is `nvim` (blocking, unix).
- `[open] prepend_rules` in `yazi.toml` maps common file types to the `edit` opener using **both MIME and name rules**. MIME rules must come first: `text/*` covers most plain-text formats, and `application/{json,toml,yaml,xml}` catches types like `application/toml` that would otherwise be dispatched to `xdg-open` (and potentially a browser). Name-based `*.toml`, `*.json`, `*.yaml`, `*.lua` rules follow as a fallback.
- The noctalia flavor uses IBM Carbon color palette: primary blue `#33b1ff`, background `#161616`, pink/magenta `#ee5396`, purple `#be95ff`, green `#42be65`.

## Flavor Structure

A flavor lives at `flavors/<name>.yazi/flavor.toml`. The directory name (without `.yazi`) is the flavor identifier used in config. Flavors define the same sections as `theme.toml` but serve as the base layer.
