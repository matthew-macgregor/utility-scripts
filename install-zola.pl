#!/usr/bin/env perl

use strict;
use warnings;
use 5.30.0;

use File::Which;
use Cwd;
use File::Path qw(make_path rmtree);

## *nix only
# -----------
die "Expected linux|openbsd|netbsd|darwin; got $^O." unless $^O =~ /(linux|openbsd|netbsd|darwin)/;

## Init Variables
# ---------------
my $home = $ENV{HOME};
if (! -d $home) {
	die "Failed to find environment variable $home";
}

my $cwd = getcwd;
my $repos_dir = "$home/Code";
my $repo_dir = "$repos_dir/zola";

make_path $repos_dir unless -d $repos_dir;
die "Failed to create $repos_dir." unless -d $repos_dir;

my $requested_version = shift @ARGV;
if (defined $requested_version) {
	die "Bad version: $requested_version" unless $requested_version =~ /v?\d+.\d+.\d+/;
	# Remove the 'v' in 'v0.17.2'
	if (index($requested_version, 'v', 0) == 0) {
		$requested_version = substr $requested_version, 1;
	}
}

my $zola_version = $requested_version // '0.17.2';
my $zola_tag = "v$zola_version";
my $zola_repo = 'https://github.com/getzola/zola.git';

my $actual_version = `zola --version`;
if ($actual_version =~ /zola \Q$zola_version/) {
 say "Zola version is already $zola_version.";
 exit 0;
}

my $cargo = which 'cargo';
my $git = which 'git';

die 'Command: cargo is missing. Install rust/cargo.' unless $cargo;
die 'Command: git is missing. Install git.' unless $git;

## Log Variables
# --------------
printf "%-25s %s\n", 'home', $home;
printf "%-25s %s\n", 'cwd', $cwd;
printf "%-25s %s\n", 'git', $git;
printf "%-25s %s\n", 'cargo', $cargo;
printf "%-25s %s\n", 'zola_version', $zola_version;
printf "%-25s %s\n", 'zola_tag', $zola_tag;
printf "%-25s %s\n", 'zola_repo', $zola_repo;
printf "%-25s %s\n", 'repos_dir', $repos_dir;
printf "%-25s %s\n", 'repo_dir', $repo_dir;

## Git Clone/Checkout Code
# ------------------------
if (! -d $repo_dir) {
	chdir $repos_dir;
	my $exit_code = system "git clone $zola_repo --branch $zola_tag --single-branch";
	die "Failed to clone $zola_repo for $zola_tag." unless $exit_code == 0;
} else {
	chdir $repo_dir;
	my $exit_code = system "git checkout tags/$zola_tag";
	die "Failed to checkout $zola_tag." unless $exit_code == 0;
}

## Build/Install
# --------------
my $exit_code = system "cargo install --path .";
die "Failed to cargo build/install Zola $zola_tag." unless $exit_code == 0;
system "git checkout master";

## Check Version
# --------------
$actual_version = `zola --version`;
die "Expected zola $zola_version but found $actual_version." unless $actual_version eq "zola $zola_version";

## Check Install
# --------------
my $zola = which 'zola';
die "Expected zola in PATH, but found none." unless defined $zola;
say "which zola: $zola";

## Cleanup
# --------
chdir $cwd;

say "Success";



