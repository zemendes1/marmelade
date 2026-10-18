#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing Neovim and LazyVim dependencies..."
# fzf/rg/fd power the pickers (fzf-lua), tree-sitter-cli builds parsers, lazygit backs <leader>gg.
brew install neovim fzf ripgrep fd tree-sitter-cli lazygit

echo "==> Configuring Neovim (LazyVim, from github.com/omerxx/dotfiles)..."
rm -rf "$HOME/.config/nvim"
mkdir -p "$HOME/.config/nvim"
cp -r "$REPO_DIR/config/nvim/." "$HOME/.config/nvim/"

# First launch bootstraps lazy.nvim and installs LazyVim + plugins (don't also run Lazy sync, it races the install).
nvim --headless +qa
# Treesitter parsers build asynchronously, so install them explicitly and wait, or headless exit aborts them.
# Drop the half-finished downloads the first launch left behind when it exited.
rm -rf "$HOME/.cache/nvim"/tree-sitter-*
nvim --headless "+lua require('lazy').load({ plugins = { 'nvim-treesitter' } })
  local spec = require('lazy.core.config').spec.plugins['nvim-treesitter']
  local opts = require('lazy.core.plugin').values(spec, 'opts', false)
  require('nvim-treesitter').install(opts.ensure_installed):wait(600000)" +qa
# Mason tools (LSPs, formatters, linters) install in the background on the first interactive launch.
echo "Neovim configured."
