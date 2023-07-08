#!/usr/bin/env perl

use v5.38.0;
#use strict;
#use warnings;

use File::Fetch;
use File::Copy;
use File::Path qw(make_path rmtree);

my $home = $ENV{HOME};
if (! -d $home) {
	die "Failed to find environment variable $home";
}
my $obsidian_version = '1.3.5';
my $obsidian_filename = "Obsidian-$obsidian_version.AppImage";
my $obsidian_url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v$obsidian_version/$obsidian_filename";
my $bin_dir = "$home/.local/bin";
my $icon_dir = "$home/.local/icons";
my $desktop_file_path = "$home/.local/share/applications/obsidian.desktop";

say "bin_dir: $bin_dir";

if (! -e $obsidian_filename) {
	say "Fetching: $obsidian_url";
	my $ff = File::Fetch->new(uri => $obsidian_url);
	my $file = $ff->fetch() or die $ff->error;
} else {
	say "Skipping download: $obsidian_url";
}

if (! -d $bin_dir) {
	mkdir($bin_dir) or die "Failed to create $bin_dir!";
}

copy($obsidian_filename, "$bin_dir/obsidian") or die "Failed to copy file $obsidian_filename to bin!";
say "Copied $obsidian_filename to $bin_dir";

chmod 0755, $obsidian_filename, "$bin_dir/obsidian" or die "Failed to set permissions for $obsidian_filename";

my $exit_code = system("./$obsidian_filename", '--appimage-extract');
if ($exit_code != 0) {
	say "Failed to extract $obsidian_filename";
} else {
	if (! -d $icon_dir) {
		say "Creating $icon_dir";
		make_path($icon_dir);
	}
	copy('squashfs-root/obsidian.png', "$icon_dir/obsidian.png") or die "Failed to copy icon to $icon_dir";
}

my $desktop_contents = <<"END_XDG";
[Desktop Entry]
Name=Obsidian
Exec=$home/.local/bin/obsidian
Terminal=false
Type=Application
Icon=$home/.local/icons/obsidian.png
StartupWMClass=obsidian
X-AppImage-Version=$obsidian_version
Comment=Obsidian
MimeType=x-scheme-handler/obsidian;
Categories=Office;
END_XDG

#print $desktop_contents;

open my $fh, '>', $desktop_file_path or die $!;
print $fh $desktop_contents;
close $fh;

if (! -f $desktop_file_path) {
	die "$desktop_file_path not found\n";
}

rmtree('squashfs-root');

say "Desktop file exported to $desktop_file_path";

$exit_code = system("xdg-desktop-menu install --novendor $desktop_file_path");
if ($exit_code != 0) {
	say "Failed to install desktop file $desktop_file_path";
}

say "Done"
