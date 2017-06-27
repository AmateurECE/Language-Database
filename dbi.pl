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
# Formats
###

format ROW =
@< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$day, $word, $meaning
.

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
	fetch($sth, $dbh) if $sql =~ m/SELECT/;
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

    my($sth, $dbh) = @_;
    my $output;
    while (my @rows = $sth->fetchrow_array) {
	my $str = join(", ", @rows);
	$output .= "\n" . $str;
    }

    select(STDOUT);
    $~ = "ROW";
    my $header = get_header($dbh);
    
    write $header;
    write $output;
}

################################################################################
# FUNCTION:	    get_header
#
# DESCRIPTION:	    Returns a string representing the header for a table --
#		    containing the names of all of the columns.
#
# ARGUMENTS:	    dbh: (Scalar) -- Database handle
#
# RETURN:	    Scalar -- header of the table
#
# NOTES:	    
###
sub get_header {

    my $dbh = shift;
    my $str = <<'SQL';
SELECT sql FROM sqlite_master
WHERE type IS 'table';
SQL
    my $sth = $dbh->prepare($str);
    $sth->execute();
    while (my @rows = $sth->fetchrow_array) {
	foreach my $row (@rows) {
	    $row =~ m/(\(.*\))/;
	    my @lines = split(",", $1);

	    my @cols;
	    foreach my $line (@lines) {
		$line =~ m/([a-z]+)/;
		push @cols, $1;
	    }
	    my $header = join(", ", @cols);
	}
    }
    return $header;
}

################################################################################
