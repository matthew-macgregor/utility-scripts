#!/usr/bin/env perl

use File::Which;
use v5.38.0;

use File::Basename;
use lib dirname (__FILE__);
use Helpers qw(is_os check_installed);

sub check_install_curl_debian {
	# ensure that curl is already installed 
	say `type curl || (sudo apt-get update && sudo apt-get install curl -y)`;
	die "Failed to find or install curl" unless $? == 0;
}

sub install_gh_debian {
		# Should work for debian, ubuntu, raspberry-pi
		say "Adding keyring.gpg.";
		say `curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd status=none of=/usr/share/keyrings/githubcli-archive-keyring.gpg`;
		die "Failed to add Github keyring." unless $? == 0;

		say "Setting permissions on keyring.gpg.";
		say `sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg`;
		die "Failed to chmod kering.gpg." unless $? == 0;

		say "Adding Github to packages.list.";
		say `echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null`;
		die "Failed to add to sources.list.d." unless $? == 0;

		say "Installing gh.";
		say `sudo apt-get update && sudo apt-get install gh -y`;
		die "Failed to install gh." unless $? == 0;
}

sub install_gh_fedora {
		# Should work for fedora, RHEL, centos, (alma, rocky?)
		say `sudo dnf install 'dnf-command(config-manager)'`;
		die "Unable to install config-manager." unless $? == 0;
		say `sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo`;
		die "Unable to add gh-cli.rep" unless $? == 0;
		say `sudo dnf install -y gh`;
		die "Unable to install gh." unless $? == 0;
}

say "OS: $^O"; # Operating System
if (check_installed 'gh') {
	say "gh is already installed.";
	exit 0;
}

if (is_os 'linux', 'debian') {
	# TODO: should we detect distribution, package manager, or both?
	say "Debian/Ubuntu: probably debian-like";
	say "Ensuring prerequisites.";
	check_install_curl_debian();
	install_gh_debian();
} elsif (is_os 'linux', 'fedora') {
	say "Fedora: probably fedora-like";
	install_gh_fedora();
} elsif (is_os 'darwin') {
	`brew install gh`
} else {
	die "Sorry, can't support '$^0' (yet)"
}

