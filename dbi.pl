#!/usr/bin/perl -w
################################################################################
# NAME:		    dbi.pl
#
# AUTHOR:	    Ethan D. Twardy
#
# DESCRIPTION:	    This perl script interfaces with the module in LanDB.pl
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

my $un = "";
my $pd = "";
my $dbh = DBI->connect("dbi:SQLite:/home/etwardy/my_work/Language-Database/test.db", "$un", "$pd", { RaiseError => 1});

my $sql = <<'EOF';
CREATE TABLE test (
    id	    INTEGER PRIMARY KEY,
    name    VARCHAR(20)
)
EOF

my $sth = $dbh->prepare($sql);
$sth->execute();

$dbh->disconnect();
