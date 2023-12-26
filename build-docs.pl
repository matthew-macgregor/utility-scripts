#!/usr/bin/env perl

use v5.38.0;
use Pod::Html;

my $css = 'https://cdn.simplecss.org/simple.min.css';
my %files = qw(Helpers.pm helpers.html);

say "Preparing to generate documentation.";

mkdir 'html';

# Note: docs are a work in progress.
foreach(keys %files) {
	say "Building $_ to html/$files{$_}"; 
	`pod2html --infile='$_' --outfile='html/$files{$_}' --css=$css`;
	die "Failed" unless $? == 0;
}

say "Success."
