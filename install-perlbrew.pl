#!/usr/bin/env perl

use warnings;
use strict;
use v5.34;

# include modules in the current directory
use File::Basename;
use lib dirname (__FILE__);
use Helpers qw(check_installed is_os);

if (check_installed('perlbrew', 1)) { # use type instead of File::Which
	say "Perlbrew is already installed.";
	say `perlbrew --version`;
	exit 0;
} else {
	say "Perlbrew is not installed.";
}

#if (not check_installed('curl')) {
#	say "Installing curl";
#	Helpers::install_curl();
#}

if (is_os 'linux', 'debian') {
	say "Updating dependencies.";
	say `sudo apt-get update`;
	die "apt-get update failed" unless $? == 0;
	# use the system package manager
	say "Installing from package manager.";
	say `sudo apt-get install -y perlbrew`;
	die "apt-get install perlbrew failed" unless $? == 0;
	
	say `echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bashrc`;
	unless ($? == 0) {
		say "Run the following command:";
		say "echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bashrc";
	}
}

#curl -L https://install.perlbrew.pl | bash
