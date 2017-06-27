#!/usr/bin/perl -w
################################################################################
# NAME:		    dbi.pl
#
# AUTHOR:	    Ethan D. Twardy
#
# DESCRIPTION:	    This perl script creates a very simple command line tool
#		    for using SQLite.
#
# CREATED:	    06/26/2017
#
# LAST EDITED:	    06/26/2017
###

################################################################################
# Includes
###

use strict;
use warnings;
use DBI;

################################################################################
# Main
###

my $dbn = "dbi:SQLite";
my $wd = $ENV{'PWD'};

print "Perl DBI Interface v1.0\n",
    "***********************\n",
    "What would you like to do?\n",
    "Open File\n",
    "Create File\n",
    "Exit\n",
    "***********************\n";
my $ans = <STDIN>;
$ans =~ s/([A-Z])/\L$1/g;
my $file;
my $action;
if ($ans =~ m/o.*/) {

    do {
	print "Please enter the name of a valid file you would like to open.\n";
	$file = <STDIN>;
	chomp $file
    } while (!-e "$wd/$file");
    $action = 'o';

} elsif ($ans =~ m/c.*/) {

    print "Please enter the name of a file you would like to create.\n";
    $file = <STDIN>;
    chomp $file;
    $action = 'c';

} elsif ($ans =~ m/e.*/) {

    exit 0;

} else {

    print "I didn't understand that command. Goodbye.\n";
    exit 0;

}

my $dbh = DBI->connect("$dbn:$file", "", "", {
    PrintError	=> 1,
    RaiseError => 1,
		       });
print "Please enter SQLite commands, terminated by the string 'EOF'.\n",
    "When you have finished, please enter exit.\n";

{
    local $/ = 'EOF';
    while (1) {

	my $sql = <STDIN>;
	$sql =~ s/[\n]//g;
	$sql =~ s/EOF//;
	last if $sql =~ m/exit/;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	fetch($sth) if $sql =~ m/SELECT/;
	print "Executed normally.\n"

    }
}
$dbh->disconnect();
print "Exiting.\n";

################################################################################
# Subroutines
###

################################################################################
# FUNCTION:	    fetch
#
# DESCRIPTION:	    Prints the result of an SQLite statement that uses the
#		    SELECT keyword.
#
# ARGUMENTS:	    sth: (Scalar) -- SQLite statement
#
# RETURN:	    void
#
# NOTES:	    prints to STDOUT.
###
sub fetch {

    my $sth = shift;
    while (my @row = $sth->fetchrow_array) {
	foreach my $str (@row) {
	    print "\t$str\n";
	}
    }

}

################################################################################
