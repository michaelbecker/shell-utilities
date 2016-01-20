#!/usr/bin/perl
#############################################################################
#
#   line_end.pl
#
#   MIT License
# 
#   Copyright (c) 2016, Michael Becker (michael.f.becker@gmail.com)
#   
#   Permission is hereby granted, free of charge, to any person obtaining a 
#   copy of this software and associated documentation files (the "Software"),
#   to deal in the Software without restriction, including without limitation
#   the rights to use, copy, modify, merge, publish, distribute, sublicense, 
#   and/or sell copies of the Software, and to permit persons to whom the 
#   Software is furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included 
#   in all copies or substantial portions of the Software.
#   
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
#   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT 
#   OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
#   THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#############################################################################
use strict;
use warnings;


sub usage() {
    print "\nUsage: line_end [filename] [dos | unix] [force]\n\n";
    print "       Normalizes a text file to either DOS or UNIX line endings\n";
    print "       Calling the script multiple times on the same file should\n";
    print "       be idempotent. This script will also normalize mixed line\n";
    print "       endings. If a file has a combination of LF / CR / CRLF\n";
    print "       line endings, after running the script they all will be either\n";
    print "       LF or CRLF\n";
    print "       If the script detects that the file is a binary file, it will\n";
    print "       not run, unless the force option has been provided.\n";
    exit -1;
}

if ((@ARGV != 2) && (@ARGV != 3)) {
    usage();
}

my $filename = $ARGV[0];
my $tempname = "$filename.$$";

my $UNKNOWN = 0;
my $DOS = 1;
my $UNIX = 2;

my $target_file_type = $UNKNOWN;
my $target_file_string = lc $ARGV[1];


if ($target_file_string =~ /dos/) {
    $target_file_type = $DOS;
}
elsif ($target_file_string =~ /nix/) {
    $target_file_type = $UNIX;
}
else {
    usage();
}

my $force_binary_conversion = 0;
if (@ARGV == 3) {
    if ($ARGV[2] =~ /force/i) {
        $force_binary_conversion = 1;
    }
}

if ($target_file_string =~ /dos/) {
    $target_file_type = $DOS;
}

if (-B $filename) {
    if ($force_binary_conversion) {
        print "WARNING! $filename appears to be a binary file! Continuing...\n";
    }
    else {
        print "ERROR! $filename appears to be a binary file!\n";
        exit -2;
    }
}


open (OLD, "< $filename") or die "Can't open $filename to read $!";
open (NEW, "> $tempname") or die "Can't open $tempname to write $!";

binmode(OLD);
binmode(NEW);

$/ = undef;
my $data_buffer = <OLD>;
my @data = split(//, $data_buffer);


if ($target_file_type == $DOS) {

    for (my $i = 0; $i < @data; $i++) {

        if (($data[$i] eq "\r") && ( (($i + 1) < @data) && ($data[$i + 1] eq "\n") )) {
            print NEW "\r\n";
            $i++;
        }
        elsif ($data[$i] eq "\r") {
            print NEW "\r\n";
        }
        elsif ($data[$i] eq "\n") {
            print NEW "\r\n";
        }
        else {
            print NEW $data[$i];
        }
    }
}
# $target_file_type == $UNIX
else {
    for (my $i = 0; $i < @data; $i++) {

        if (($data[$i] eq "\r") && ( (($i + 1) < @data) && ($data[$i + 1] eq "\n") )) {
            print NEW "\n";
            $i++;
        }
        elsif ($data[$i] eq "\r") {
            print NEW "\n";
            continue;
        }
        elsif ($data[$i] eq "\n") {
            print NEW "\n";
        }
        else {
            print NEW $data[$i];
        }
    }
}


close (OLD);
close (NEW);

rename ($filename, "$filename.bak") or die "Can't rename $filename to $filename.bak $!";
rename ($tempname, $filename) or die "Can't rename $tempname to $filename $!";


