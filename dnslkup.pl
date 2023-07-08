#!/usr/bin/env perl

use v5.35.0;
use Net::DNS::Resolver;

my $default_ns = [qw(10.5.0.1)];
my ($hostname,) = @ARGV;

if (not defined $hostname) {
  print "Enter the hostname you want to check: ";
  $hostname = <STDIN>;
  chomp($hostname);
}

my $res = Net::DNS::Resolver->new(nameservers => $default_ns);

my $query = $res->search($hostname);

if ($query) {
  foreach my $rr ($query->answer) {
    next unless $rr->type eq "A";
    say "Found an A record for '$hostname': ".$rr->address;
  }
} else {
  exit 1;
}
