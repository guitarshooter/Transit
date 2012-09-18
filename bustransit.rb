# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'kconv'
require 'date'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'

helpers do
  include Rack::Utils; alias_method :h, :escape_html
end

#template :layout do
#'<html>
#<head>
#<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
#<link rel="stylesheet" href="transit.css" type="text/css" media="all">
#<link rel="stylesheet" href="http://i.yimg.jp/images/transit/09/v3/css/a020_cmb.css?v=201206" type="text/css" media="all">
#</head>
#<body>
#<%= yield %>
#</body></html>
#'
#end

get '/' do
  haml :index
end

get '/result' do
busurl = 'http://transfer.navitime.biz/bus-navi/pc/transfer/TransferTop'
trainurl = 'http://transit.loco.yahoo.co.jp'
bus_from = '宇津木台中央'
bus_to = '日野駅'
train_from = '日野(東京都)'
train_to = params[:to]
h = params[:h]
m = params[:m]
@transittime = params[:tt].to_i
 
agent = Mechanize::new
 
agent.get(busurl)
 
agent.page.form_with(:name => 'train'){|form|
  form.field_with(:name => 'orvName').value = bus_from.toutf8
  form.field_with(:name => 'dnvName').value = bus_to.toutf8
  form.field_with(:name => 'hour').value = h.toutf8
  form.field_with(:name => 'minute').value = m.toutf8
  form.click_button
}
 
# puts agent.page.css("#result_area_table") 
#agent.page.search("table[@class='result_area_table']").each do |elem|
bus_elem = agent.page.at("[@class='result_area_table']")
#text
@bus_text = bus_elem.inner_html
@bus_text = "<table>" + @bus_text + "</table>"
@bus_text = @bus_text.sub(' width="60"',' width="75"') #時間
@bus_text = @bus_text.sub(' width="335"',' width="300"')
#bus_text = @bus_text.sub(' width="240"',' width="150"')
@bus_text = @bus_text.sub(' width="240" class="result_area_fare_td2" align="right" colspan="2"',' width="150" align="left" colspan="2" style="padding-left:50px"')
time_elem = bus_elem.search("tr[@class='result_area_tr']")
bus_arvtime = time_elem.pop.at('td').inner_text
bus_arvtime = bus_arvtime.sub("着","")
#bus_text
date = Time.strptime(bus_arvtime,"%H:%M")
date = date + @transittime*60
#puts date.strftime("%H:%M")
hh = date.strftime("%H")
mm = date.strftime("%M")
m1 = mm[0..0] 
m2 = mm[1..1] 

agent.get(trainurl)
 
agent.page.form_with(:name => 'search'){|form|
  form.field_with(:name => 'from').value = train_from.toutf8
  form.field_with(:name => 'to').value = train_to.toutf8
  form.field_with(:name => 'hh').value = hh.toutf8
  form.field_with(:name => 'm1').value = m1.toutf8
  form.field_with(:name => 'm2').value = m2.toutf8
  form.click_button
}
elem = agent.page.at("[@class='route']")
#puts agent.page.at("[@class='route-head']")
@train_text = elem.inner_html
elem2 = agent.page.at("[@class='infomation']")
@infomation = '<div class="infomation">' + elem2.inner_html + '</div>'
elem3 = agent.page.at("[@class='infomation2']")
@infomation = @infomation + '<div class="infomation2">' + elem3.inner_html + '</div>'
elem4 = agent.page.at("[@class='route-head']")
@routehead = elem4.inner_html
@routehead = @routehead.sub(/<ul class="service">.+<\/ul>/,"")
#@infomation = '<div class="route-head">' + @routehead +  @infomation + '</div>'
@infomation = '<div class="route-head">' + @routehead + '</div>'

#train_text = bus_text + '<div class="route">' + train_text + '</div>'
@train_text = @infomation + '<div class="route">' + @train_text + '</div>'
#train_text
haml :result
end
