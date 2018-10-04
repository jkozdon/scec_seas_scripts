#!/usr/bin/perl
# This script modified from:
#    http://www.willmaster.com/library/manage-forms/using_perl_to_submit_a_form.php

# This script deletes the all the data in the given scec test problem


use strict;
use warnings;

my $SCEC_CVWS = "http://scecdata.usc.edu/cvws/cgi-bin/seas.cgi";

my $NARGS = $#ARGV+1;
if ($NARGS < 4)
{
  print "Usage:      scec_seas_download_data.pl USER_NAME PASSWORD PROBLEM_NUMBER USER_DATA\n";
  print "Example #1: scec_seas_download_data.pl foo oihasdf 1 bar\n";
  print "Example #2: scec_seas_download_data.pl foo oihasdf 1 bar.2\n";
  exit;
}

my $UNAME = $ARGV[0];

my $PSSWD = $ARGV[1];

my $BP   = "bp$ARGV[2]";

my $USER_DATA = $ARGV[3];

print "Confirm the following download information (y/n):\n";
print "   user name: $UNAME\n";
print "   problem:   $BP\n";
print "   user_date: $USER_DATA\n";

chomp(my $input = <STDIN>);
if(lc(substr($input,0,1)) ne 'y')
{
  print "cancelling with input: $input\n";
  exit 0;
}

my %LIST_DATA = (
  "G1090$UNAME" => "Select",
  "u"          => $UNAME,
  "p"          => $PSSWD,
  "m"          => $BP,
  "urv"        => $UNAME,
  "o"          => "1005"
);

# Modules with routines for making the browser.
use LWP::UserAgent;
use LWP::Simple;
use HTTP::Request::Common;


# Create the browser that will post the information.
my $Browser = new LWP::UserAgent;

# Post the information to the CGI program.
my $Page = $Browser->request(POST $SCEC_CVWS,\%LIST_DATA);

if ($Page->is_success)
{

  # Check the info provided
  if(index($Page->content,"Forbidden Operation") != -1)
  {
    print "Username or password is likely wrong\n";
    exit 1;
  }
  if(index($Page->content,"Benchmark Not Found") != -1)
  {
    print "Benchmark $BP not found\n";
    exit 2;
  }

  foreach (split(/\n/,$Page->content))
  {
    $_ =~ /"G1027([^"]+)"/ || next;
    my ($station) = ($1);
    print "Downloading: $station\n";

    my %DOWNLOAD_CMD = (
      "G1059".$station=>"Raw Data",
      "u"=>$UNAME,
      "p"=>$PSSWD,
      "m"=>$BP,
      "o"=>"1005",
      "mus"=>$USER_DATA,
    );

    my $PageDownload = $Browser->request(POST $SCEC_CVWS,\%DOWNLOAD_CMD);
    my $filename = $USER_DATA."_".$BP."_".$station.".dat";
    print "Saving: $filename\n";
    open(FH, '>', $filename) or die $!;
    my $pre = 0;
    foreach (split(/\n/,$PageDownload->content))
    {
      if ($_ =~ /<pre>(.*)/)
      {
        print FH "$1\n";
        $pre = 1
      }
      elsif($pre)
      {
        if ($_ =~ /<\/pre>/)
        {
          $pre = 0
        }
        else
        {
          print FH "$_\n";
        }
      }
      elsif ($_ =~ /(User:.*)<br>/)
      {
        print FH "# $1\n"
      }
      elsif ($_ =~ /(File.*)<\/th>/)
      {
        print FH "# $1\n"
      }
    }
    close(FH);
  }
}
