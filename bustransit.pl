#!/usr/bin/perl

use WWW::Mechanize;
use Data::Dumper;
use HTML::TreeBuilder;
use Time::Piece;
use utf8;

my $url = 'http://transfer.navitime.biz/bus-navi/pc/transfer/TransferTop';
my $bus_from = '宇津木台中央';
my $bus_to = '日野駅';

my $mech = new WWW::Mechanize(autocheck => 1,cookie_jar => {});
#$mech->agent_alias('Windows IE 6'); #IE6になりすます


$mech->get($url); #ログインページにアクセス
$mech->submit_form(
form_name => "train",
fields => {
orvName => $bus_from,
dnvName => $bus_to,
hour => "18",
minute => "10"
}
);

$txt = $mech->content;
my $tree = HTML::TreeBuilder->new;
$tree->parse($txt);
$table = $tree->look_down("class","result_area_table");
@time = $table->look_down("class","result_area_tr");
print $table->as_HTML;
$lasttime = pop(@time);
$lasttimestr = $lasttime->find('td')->as_text;
$lasttimestr =~ s/着//g;
print $lasttimestr;
$date1 = localtime->strptime($lasttimestr,'%H:%M');
$date1 += 60*10;
print $date1->strftime('%H:%M');

exit;

