#!/usr/bin/perl
# This script modified from:
#    http://www.willmaster.com/library/manage-forms/using_perl_to_submit_a_form.php

# This script uploads data in for a given scec test problem

use strict;
use warnings;

my $SCEC_CVWS = "http://scecdata.usc.edu/cvws/cgi-bin/seas.cgi";

my $NARGS = $#ARGV+1;
if ($NARGS != 5 && $NARGS != 6)
{
  print "Usage:   scec_seas_upload_data.pl USER_NAME PASSWORD PROBLEM_NUMBER PREFIX POSTFIX\n";
  print "Usage:   scec_seas_upload_data.pl USER_NAME USER_PROBLEM_NUMBER PASSWORD PROBLEM_NUMBER PREFIX POSTFIX\n";
  print "Example: scec_seas_upload_data.pl user pass 1\n";
  print "Example: scec_seas_upload_data.pl user 2 pass 1\n";
  exit;
}

my $k = 0;
my $UNAME = $ARGV[$k];

my $URNM  = $UNAME;
if($NARGS == 6)
{
  $k = $k+1;
  $URNM  = "$UNAME.$ARGV[$k]";
}

$k = $k+1;
my $PSSWD = $ARGV[$k];

$k = $k+1;
my $TPV   = "bp$ARGV[$k]";

my $directory = '.';

$k = $k+1;
my $prefix  = $ARGV[$k];

$k = $k+1;
my $postfix = $ARGV[$k];

print "Confirm the following upload information (y/n):\n";
print "   user name: $UNAME\n";
print "   user num:  $URNM\n";
print "   problem:   $TPV\n";
print "   prefix:    $prefix\n";
print "   postfix:   $postfix\n";

chomp(my $input = <STDIN>);
if(lc(substr($input,0,1)) ne 'y')
{
  print "cancelling with input: $input\n";
  exit 0;
}

# Modules with routines for making the browser.
use LWP::UserAgent;
use HTTP::Request::Common;

# Create the browser that will post the information.
my $Browser = new LWP::UserAgent;

opendir (DIR, $directory) or die $!;

while (my $file = readdir(DIR)) {

  if(index($file,"fltst") != -1)
  {
    $file =~ /^$prefix((fltst).*)$postfix$/ || next;

    my ($station) = ($1);
    print "\nStation name: $station\n";
    print "Filename:     $file\n";

    my $Page_upload = $Browser->post(
      $SCEC_CVWS,
      [
        "file"=>[$file],
        "G1029"=>"Click Once to Upload",
        "u"=>$UNAME,
        "p"=>$PSSWD,
        "m"=>$TPV,
        "s"=>$station,
        "urv"=>$URNM,
        "o"=>"1005",
      ],
      'Content_Type' => 'form-data',);

    if(index($Page_upload->content,"Data File Not Found") != -1)
    {
      print "   >>>>> Upload Failed!\n";
      print "   >>>>> Likely '$station' is an invalid station name\n";
    }
    elsif(index($Page_upload->content,"Upload Fail") != -1)
    {
      print "   >>>>> Upload Failed!\n";
      foreach (split(/\n/,$Page_upload->content))
      {
        if(index($_,"Error") != -1)
        {
          print "   >>>>> $_\n";
        }
      }
    }
  }
  else
  {
    $file =~ /$prefix(.*)$postfix/ || next;
    print "\nUknown file type\n";
    print "Filename:     $file\n";
  }
}

closedir(DIR);
exit 0;

