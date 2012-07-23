#!/usr/bin/perl

use WWW::Mechanize;
use Data::Dumper;
use HTML::TreeBuilder;
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
dnvName => $bus_to
}
);

$txt = $mech->content;
my $tree = HTML::TreeBuilder->new;
$tree->parse($txt);
$table = $tree->look_down("class","result_area_table");
print $table->as_HTML;
#foreach $tag (@table){
#  print $tag->as_HTML,"\n";
#}

#print $txt;
exit;

@line = split("\n",$txt); #ページを行で分割
@btn = ();

foreach $row (@line){
if($row =~ m/javascript:PostBack_Btn1\((.+?)\)/){ #配信結果IDを取得
$no = $1;
push(@btn,$no);
}
}

