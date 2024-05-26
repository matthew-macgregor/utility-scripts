package Helpers;

use warnings;
use strict;
use base 'Exporter';
use feature 'say';
our @EXPORT_OK = qw(check_installed get_linux_os_release is_os);

use File::Which;

sub parse_linux_os_release {
	my @os_param = split /=/, shift;
	foreach(@os_param) { $_ =~ s/^\s+|\s+$//g; }
	return ($os_param[0], $os_param[1]);
}

sub get_linux_os_release {
	my $os_release_str = shift;
	my %os=();

	# Parse key,values from a string
	if (defined $os_release_str) {
		foreach (split(/\n/, $os_release_str)) {
			my ($k, $v) = parse_linux_os_release $_;
			$os{$k} = $v;
		}
	# Parse key,values from `/etc/os-release`
	} else {
		my $filepath="/etc/os-release";
	
		my $OS;
		if (not open($OS, '<', $filepath)) {
			return %os;
		}
		
		while (<$OS>){
			my ($k, $v) = parse_linux_os_release $_;
			$os{$k} = $v;
		}
	}

	return %os;
}


sub get_exe_path {
	my $cmd = shift;
	chomp($cmd);
	return which $cmd;
}

sub check_installed {
	my ($cmd, $fallback) = @_;
	if (defined $fallback) {
		# if File::Which is not installed (it's not by default on Ubuntu)
		# fall back to running `type` instead.
		`sh -c 'type $cmd'`;
		return $? == 0 ? 1 : 0;
	}

	my $result = get_exe_path($cmd);
	return (!defined $result) || ($result =~ /^\s*$/) ? 0 : 1;
}

sub is_os {
	my ($os_str, $dist_str) = @_;
	if ($^O =~ /$os_str/) {
		if ($os_str eq 'linux') {
		 	if (defined $dist_str) {
				my %os_hash = get_linux_os_release();
				my $dist_id = $os_hash{ID};
				return ($dist_str =~ /$dist_id/) ? 1 : 0;
			}
		} else {
			die "$dist_str is not compatible with $os_str" unless not defined $dist_str;
		}	
		
		return 1;
	}
	
	return 0;
}

sub install_curl {
	if ($^O eq 'linux') {
		# might be "debian ubuntu" or "fedora" or "debian ubuntu pop"
		my %os_hash = get_linux_os_release();
		my $linux_id = $os_hash{ID_LIKE} . " " . $os_hash{ID};
		
		# TODO: should we detect distribution, package manager, or both?
		if ($linux_id =~ /debian/) {
			say "Debian: probably debian-like";
			install_curl_debian();
		} elsif ($linux_id =~ /fedora/) {
			say "Fedora: probably fedora-like";
			install_gh_fedora();
		}
	} elsif ($^O eq 'darwin') {
		`brew install curl`
	} else {
		die "Sorry, can't support OS: '$^0' (yet)."
	}
}

sub install_curl_debian {
	# ensure that curl is already installed 
	say `type curl || (sudo apt-get update && sudo apt-get install curl -y)`;
	die "Failed to find or install curl" unless $? == 0;
}

1;

=pod

=head1 Helper Utilities

C<Helpers.pm> provides utility functions for setup tasks on macOS, Linux, and possibly other unixes.

=head2 Functions

=over

=item C<get_linux_os_release [$os_release as string]>

OS: unix

C<get_linux_os_release> returns a hash with the values in C</etc/os-release>, or an empty hash if that file doesn't exist. If a string parameter is passed, it will be used instead of the contents of C</etc/os-release>.

Example keys and values from the hash:

	NAME="Pop!_OS"
	VERSION="22.04 LTS"
	ID=pop
	ID_LIKE="ubuntu debian"
	PRETTY_NAME="Pop!_OS 22.04 LTS"
	VERSION_ID="22.04"
	HOME_URL="https://pop.system76.com"
	SUPPORT_URL="https://support.system76.com"
	BUG_REPORT_URL="https://github.com/pop-os/pop/issues"
	PRIVACY_POLICY_URL="https://system76.com/privacy"
	VERSION_CODENAME=jammy
	UBUNTU_CODENAME=jammy


=item C<is_os $os_str (as string), [$dist_str (as string)]>

Function C<is_os> accepts a string C<$os_str> parameter ('linux', 'darwin', etc.), and optionally on linux a C<$dist_str> parameter ('debian', 'pop', 'ubuntu', etc.).

=back

=cut
