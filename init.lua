--------------------------------------------------------------------------------
-- Lazy bootstrap
--------------------------------------------------------------------------------

-- used by CrispyDrone/vim-tasks
-- has to be done befor Lazy is loaded
-- TODO: move to tuning.lua... How??
vim.g.maplocalleader = " "
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = "," -- leader
require("lazy").setup("plugins")

-- load sub config files
require "tuning"
require "extras"
