#!/usr/bin/env perl

use strict; # not needed after v5.35.0
use warnings;
use feature 'say';

sub get_linux_os_release {
	my %os=();
	my $filepath="/etc/os-release";
	
	unless (open(OS, '<', $filepath)) {
		die("Failed to open '$filepath'.");
	}
	 
	while (<OS>){
	    my @os_param = split /=/, $_;
		chomp($os_param[1]);
		$os{$os_param[0]}=$os_param[1];
	}

	# NAME="Pop!_OS"
	# VERSION="22.04 LTS"
	# ID=pop
	# ID_LIKE="ubuntu debian"
	# PRETTY_NAME="Pop!_OS 22.04 LTS"
	# VERSION_ID="22.04"
	# HOME_URL="https://pop.system76.com"
	# SUPPORT_URL="https://support.system76.com"
	# BUG_REPORT_URL="https://github.com/pop-os/pop/issues"
	# PRIVACY_POLICY_URL="https://system76.com/privacy"
	# VERSION_CODENAME=jammy
	# UBUNTU_CODENAME=jammy
	
	return %os;
}

sub check_installed {
	my $cmd = shift @_;
	say `sh -c 'type $cmd'`;
	return $? == 0 ? 1 : 0;
}

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
		say `sudo dnf install gh`;
		die "Unable to install gh." unless $? == 0;
}

say "OS: $^O"; # Operating System
if (check_installed 'gh') {
	say "gh is already installed.";
	exit 0;
}


if ($^O eq 'linux') {
	# might be "debian ubuntu" or "fedora" or "debian ubuntu pop"
	my %os_hash = get_linux_os_release();
	my $linux_id = $os_hash{ID_LIKE} . " " . $os_hash{ID};
	# say $os_hash{ID_LIKE};
	# say $os_hash{ID};
	say "OS Release Id: $linux_id";
	
	# TODO: should we detect distribution, package manager, or both?
	if ($linux_id =~ /debian/) {
		say "Debian/Ubuntu: probably debian-like";
		say "Ensuring prerequisites.";
		check_install_curl_debian();
		install_gh_debian();
	} elsif ($linux_id =~ /fedora/) {
		say "Fedora: probably fedora-like";
		install_gh_fedora();
	}
} elsif ($^O eq 'darwin') {
	`brew install gh`
} else {
	die "Sorry, can't support '$^0' (yet)"
}


