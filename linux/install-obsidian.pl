#!/usr/bin/env perl

use v5.38.0;
#use strict;
#use warnings;

use File::Fetch;
use File::Copy;
use File::Path qw(make_path rmtree);
use Cwd;


## Init Variables
# ---------------
my $home = $ENV{HOME};
if (! -d $home) {
	die "Failed to find environment variable $home";
}
my $cwd = getcwd;
my $requested_version = shift @ARGV;
my $obsidian_version = $requested_version // '1.3.5';
my $obsidian_filename = "Obsidian-$obsidian_version.AppImage";
my $obsidian_url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v$obsidian_version/$obsidian_filename";
my $bin_dir = "$home/.local/bin";
my $squashfs_root = "$cwd/squashfs-root";
my $icon_dir = "$home/.local/icons";
my $icon_src_file_path = "$squashfs_root/usr/share/icons/hicolor/512x512/apps/obsidian.png";
my $icon_dest_file_path = "$icon_dir/obsidian.png";
my $desktop_dest_file_path = "$home/.local/share/applications/obsidian.desktop";

## Log Variables
# --------------
printf "%-25s %s\n", 'obsidian_version', $obsidian_version;
printf "%-25s %s\n", 'bin_dir', $bin_dir;
printf "%-25s %s\n", 'obsidian_filename', $obsidian_filename;
printf "%-25s %s\n", 'bin_dir', $bin_dir;
printf "%-25s %s\n", 'icon_dir', $icon_dir;
printf "%-25s %s\n", 'desktop_dest_file_path', $desktop_dest_file_path;
printf "%-25s %s\n", 'home', $home;

## Create Directories
# -------------------
if (! -d $bin_dir) {
	mkdir($bin_dir) or die "Failed to create $bin_dir!";
}

if (! -d $icon_dir) {
	say "Creating $icon_dir";
	make_path($icon_dir);
}

## Fetch AppImage
# ---------------
if (! -e $obsidian_filename) {
	say "Fetching: $obsidian_url";
	my $ff = File::Fetch->new(uri => $obsidian_url);
	my $file = $ff->fetch() or die $ff->error;
} else {
	say "Skipping download: $obsidian_url";
}

## Copy AppImage to bin and chmod +x
# ----------------------------------
copy($obsidian_filename, "$bin_dir/obsidian") or die "Failed to copy file $obsidian_filename to bin!";
say "Copied $obsidian_filename to $bin_dir";
chmod 0755, $obsidian_filename, "$bin_dir/obsidian" or die "Failed to set permissions for $obsidian_filename";

## Extract AppImage
# -------------------
my $exit_code = system("./$obsidian_filename --appimage-extract usr/share/icons/hicolor/512x512/apps/obsidian.png");
if ($exit_code != 0) {
	say "Failed to extract $obsidian_filename";
} else {
	if (! -f $icon_src_file_path) { die "Failed to find $icon_src_file_path"; }
	copy($icon_src_file_path, $icon_dest_file_path) or die "Failed to copy icon to $icon_dir";
}

## Prepare Desktop File
# ---------------------
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

## Write Desktop File
# -------------------
open my $fh, '>', $desktop_dest_file_path or die $!;
print $fh $desktop_contents;
close $fh;

if (! -f $desktop_dest_file_path) {
	die "$desktop_dest_file_path not found\n";
}
say "Desktop file exported to $desktop_dest_file_path";

## Cleanup
# --------
rmtree($squashfs_root);
say "Cleanup completed";

## Register Desktop File
# ----------------------
$exit_code = system("xdg-desktop-menu install --novendor $desktop_dest_file_path");
if ($exit_code != 0) {
	say "Failed to install desktop file $desktop_dest_file_path";
}

say "Success"
