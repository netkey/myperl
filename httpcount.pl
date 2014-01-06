#!/usr/bin/perl
#这个脚本是统计那个资源是最热门的
#给出点击率，主要是针对文件
use strict;
my $log_file='D:\\test\\log.txt';
#my $out_file='new_log.txt';
open FH,"<",$log_file||die "can't open $log_file:$!\n";
printf("%10s%71s\n",'file','hits');
my @info;
my %count;
while(<FH>)
{
   @info=split;
   if(exists $count{$info[5]})
   {
      $count{$info[5]}++;
   }
   else
   {
       $count{$info[5]}=1;
   }
}   
map{printf("%-70s%10d\n",$_,$count{$_})} sort {$count{$b}<=>$count{$a}} keys %count;
#print map{"$_\t$count{$_}\n"} sort {$count{$b}<=>$count{$a}} keys %count;

#这个perl脚本等价于 awk -F" " '{++S[$6]} END {for(a in S) print a,S[a]}' log.txt |sort -r -n -k 2
