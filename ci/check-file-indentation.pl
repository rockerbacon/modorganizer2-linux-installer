#!/usr/bin/env perl

use autodie;
use strict;
use warnings;
use File::Find;
use Term::ANSIColor;

sub filter_entries {
	my @valid_entries=();
	foreach (@_) {
		if (
			-d and ! /^\.[!\.]/
			or
			-f and /\.(sh|pl)/
		) {
			push(@valid_entries, $_);
		}
	}

	return @valid_entries;
}

sub check_indentation {
	open (my $file_handle, "<", $_);

	while (<$file_handle>) {
		if (/^\s* /) {
			return 1;
		}
	}

	return 0;
}

my $fails = 0;
sub check_dir_entry {
	if (! -f) {
		return 0;
	}

	print "$File::Find::name:";

	if (! check_indentation) {
		print colored(" OK", "green");
	} else {
		print colored(" INCORRECT", "red");
		$fails++;
	}

	print "\n";
};

my %find_options = (
	preprocess => \&filter_entries,
	wanted => \&check_dir_entry,
);

find(\%find_options, filter_entries @ARGV);

print "\n";
if ($fails) {
	print colored("Indentation check failed!\n", "red");
	print "Make sure to indent files using tabs\n";
} else {
	print colored("All files are OK!\n", "green");
}

exit $fails;

