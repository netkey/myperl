#!/usr/bin/perl
#
use strict;
use warnings;
use XML::Simple;
use LWP::Simple;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use Log::Minimal;
use File::Stamped;

my $fh = File::Stamped->new(pattern => 'speedtest_%Y%m.log');
local $Log::Minimal::AUTODUMP = 1;
local $Log::Minimal::PRINT = sub {
    my ($time, $type, $message, $strace) = @_;
    print {$fh} "$time [$type] $message\n";
};

my $xmlurl = "http://test.test.com/LoadSpeed/LoadSpeed.xml";
my $agent=new LWP::UserAgent();
$agent->timeout(10);
$agent->env_proxy;

my $request = new HTTP::Request('GET'=>$xmlurl);
my $response = $agent->request($request);
if ($response->is_success)
{
infof("xml file download success");
my $document = $response->content();
my $xml = new XML::Simple;
my $xmldata = $xml->XMLin($document,KeyAttr=>"TaskId");
#print Dumper($xmldata);
warnf("xmldata dump is %s",$xmldata);
my %alltasks = %{$xmldata->{LoadSpeed}};

  foreach my $key (keys %alltasks)
  {
    print $key;
    my $TaskUrl = $alltasks{$key}{"TaskUrl"};
    my $StartTime = $alltasks{$key}{"StartTime"};
    my $EndTime = $alltasks{$key}{"EndTime"};
    my $State = $alltasks{$key}{"State"};
    my $NowTime = localtime(time());
    if($State==1)
    {
        infof("task $key is available!");
        my $speed = DownSpeed($TaskUrl);
        infof("task $key speed is $speed!");
        PostSpeed($speed,$key) if $speed > 0;
    }
  }
}

sub DownSpeed
{
  my $url = shift;
  my ($filesize,$size,$filename);
  my @header = head($url);
  my $speed = 0;

  if (@header) {
  
  $filesize = $header[1];

  my @url_arr = split(/\//,$url);
  $filename = $url_arr[-1];
  unlink($filename) if -e $filename;

  my $start_time = time;
  getstore($url, $filename);
  my $end_time = time;
  my $time_use = $end_time - $start_time;
  my @status = stat($filename);
  $size = $status[7];
  if ($filesize == $size && $time_use != 0) {
    infof("download completed!");
    $speed = $filesize / 1024 / $time_use;
    unlink $filename;
  }

  }

  $downspeed = int($speed);
  DownSpeed($url) if $downspeed == 0;
  return $downspeed;

}

sub PostSpeed
{
  my ($speed,$task_id) = @_;
  my $url = "http://test.test.com/LoadTest/RequestData.php";
  my $ua = LWP::UserAgent->new;
  my $req = POST $url,[loadspeed => $speed, TaskId => $task_id];
  $ua->request($req);
}
