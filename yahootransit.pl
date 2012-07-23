#!/usr/bin/perl

use WWW::Mechanize;
use Data::Dumper;
use HTML::TreeBuilder;
use utf8;

my $url = 'http://transit.loco.yahoo.co.jp/';
my $train_from = '日野(東京都)';
my $train_to = '京橋(東京都)';

my $mech = new WWW::Mechanize(autocheck => 1,cookie_jar => {});
#$mech->agent_alias('Windows IE 6'); #IE6になりすます


$mech->get($url); #ログインページにアクセス
$mech->submit_form(
form_name => "search",
fields => {
from => $train_from,
to => $train_to,
hh => "06",
m1 => "0",
m2 => "5"
}
);

$txt = $mech->content;
my $tree = HTML::TreeBuilder->new;
$tree->parse($txt);
$table = $tree->look_down("class","route");
print <<HTML;
<html>
<head>
<link rel="stylesheet" href="http://i.yimg.jp/images/css/printexec.css" type="text/css" media="print">
<link rel="stylesheet" href="http://i.yimg.jp/images/transit/09/v3/css/a020_cmb.css?v=201206" type="text/css" media="all">
</head>

HTML

print $table->as_HTML;

exit;

@line = split("\n",$txt); #ページを行で分割
@btn = ();

foreach $row (@line){
if($row =~ m/javascript:PostBack_Btn1\((.+?)\)/){ #配信結果IDを取得
$no = $1;
push(@btn,$no);
}
}

