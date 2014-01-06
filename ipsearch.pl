#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use LWP::UserAgent;
use LWP::Simple;
use HTTP::Request::Common;
use Encode;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

my $filename = $ARGV[0];
my %opts = (charset_strict  => 1,         
             default_charset => 'gb2312',
            );
open(FILE, $filename) || die "open the file failed!\n";
while(my $line=<FILE>)
{
  chomp($line);
  my $url = "http://www.ip138.com/ips1388.asp?ip=$line&action=2";
  my $request = new HTTP::Request('GET'=>$url);
  my $agent=new LWP::UserAgent();
  $agent->timeout(10);
  my $response = $agent->request($request);
  if ($response->is_success)
  {
    my $data = $response->decoded_content(%opts);
    #my $out = encode("gb2312",$data);
    #print $data;
    if ($data =~ m/本站主数据：(.+?)<\/li>/)
    {
        my $diqu = $1;
        print "$line\t $diqu\n";
    }
  }
}
close(FILE);

