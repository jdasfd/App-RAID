#!/usr/bin/perl -w
#
# A simple script for extracting pfam info.
#
# Author: Yuqian Jiang
# Created: 2023-06-14

# Change logs:
# Version: 1.0.0 23-06-14: The initial version.
# Version: 1.0.1 23-06-28: Bug fixes: Col3 DESC will remove the first _, add a judge of the input file.

use strict;
use warnings;
use autodie;
use Path::Tiny;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

=head1 NAME

hmm_info.pl - extract info from .hmm files

=head1 SYNOPSIS

    perl hmm_info.pl <input_file> > info.tsv
    A script for extracting info from pfam-hmm database.

    Options:
    help: show help message
=cut

my $input = $ARGV[0];

die usage() if $input eq "help";
if ( !defined $input ) {
    die ("Input a file please.")
}
elsif ( !path($input) -> is_file ) {
    die ("Error: can't find file [$input].");
}
elsif ( !$input =~ /\.hmm.*$/ ) {
    die ("Error: input a .hmm file please.");
}

#----------------------------------------------------------#
# init
#----------------------------------------------------------#

my ($readline, $line_num);
my @output = ();

open my $fh_in, '<', $input;
while( <$fh_in> ) {
    $line_num++;
    if ( $_ =~ /\/\// ) {
        if ( $readline =~ /NAME\s+?(\w.*?)\nACC\s+?(\w.+?)\nDESC\s+?(.+?)\nLENG\s+(\d+?)\n/ ){
            my $NAME = $1;
            my $ACC = $2;
            my $DESC = $3;
            my $LENG = $4;
            $DESC =~ s/\s/_/g;
            $DESC =~ s/^_//;
            my $for_print = "$NAME\t$ACC\t$DESC\t$LENG\n";
            push @output, $for_print;
            $readline = "";
        }
        else {
            print STDERR "Warning: HMM info extraction failed at line $line_num.\n";
            $readline = "";
        }
    }
    elsif ( $_ =~ /^\w/) {
        $readline .= $_;
    }
    else {
        next;
    }
}

close $fh_in;

print "NAME\tACC\tDESC\tLENG\n";
foreach (@output) {
    print $_;
}

sub usage{
    my $help_str = <<"EOF";
    perl hmm_info.pl <input_file> > info.tsv
    A script for extracting info from pfam-hmm database.

    Options:
    help: show help message
EOF
    return $help_str;
}
