#!/usr/bin/env perl

use warnings;
use strict;
use v5.38;

# include modules in the current directory
use File::Basename;
use lib dirname (__FILE__);
use Helpers qw(check_installed is_os);

if (check_installed('rbenv')) {
	say "rbenv is already installed.";
	say `rbenv --version`;
  #	exit 0;
} else {
	say "rbenv is not installed.";
}

# NOTE: not using package managers for Ubuntu because rbenv is badly out of date there.

my $rbenv_root = glob('~/.rbenv');
say "rbenv_root = $rbenv_root";

warn "~/.rbenv already exists!" if -d $rbenv_root;
if (is_os 'linux', 'debian') {
  say `type git || (sudo apt-get update && sudo apt-get install git -y)`;
	die "Failed to find or install git" unless $? == 0;

	say `git clone https://github.com/rbenv/rbenv.git $rbenv_root`;
	die "Failed to clone rbenv." unless $? == 0;
	
	say `echo 'eval "\$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc`;
	die "Failed to add rbenv to `.bashrc`" unless $? == 0;
	
	say `git clone https://github.com/rbenv/ruby-build.git "\$(rbenv root)"/plugins/ruby-build`;
	die "Failed to clone ruby-build." unless $? == 0;
	
	say "Installing build dependencies.";
	say `sudo apt-get install -y autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev rust-all`;
	die "Failed to install build dependencies." unless $? == 0;
} elsif (is_os 'linux', 'fedora') {
	say `type git || (sudo dnf install -y git)`;
	die "Failed to find or install git" unless $? == 0;

	say `git clone https://github.com/rbenv/rbenv.git ~/.rbenv`;
  die "Failed to clone rbenv." unless ($? == 0 or -e "$rbenv_root");
	
	say `echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bash_profile`;
	die "Failed to add rbenv to `.bashrc`" unless $? == 0;
	
  #$rbenv_root = `rbenv root`; # let's ask rbenv where it lives
  #die "Failed to find rbenv root." unless $? == 0;

	say `git clone https://github.com/rbenv/ruby-build.git "$rbenv_root"/plugins/ruby-build`;
	die "Failed to clone ruby-build." unless ($? == 0 or -e "$rbenv_root/plugins/ruby-build");
	
	say "Installing build dependencies.";
	say `sudo dnf install -y autoconf gcc rust patch make bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel`;
	die "Failed to install build dependencies." unless $? == 0;
} elsif (is_os 'darwin') {
	say "Installing from homebrew";
	say `brew install rbenv ruby-build`;
	die "brew rbenv failed" unless $? == 0;
	
	# install Xcode Command Line Tools
	say `xcode-select --install`;
	die "xcode-select install failed" unless $? == 0;

	# install dependencies with Homebrew
	say "Installing build dependencies.";
	say `brew install openssl\@3 readline libyaml gmp rust`;
	die "brew install build dependencies failed." unless $? == 0;
}
