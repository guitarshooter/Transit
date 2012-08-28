# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'kconv'
require 'date'

busurl = 'http://transfer.navitime.biz/bus-navi/pc/transfer/TransferTop'
trainurl = 'http://transit.loco.yahoo.co.jp';
bus_from = '宇津木台中央'
bus_to = '日野駅'
train_from = '日野(東京都)';
train_to = '京橋(東京都)';
h = '18'
m = '10'
 
agent = Mechanize::new
 
agent.get(busurl)
 
agent.page.form_with(:name => 'train'){|form|
  form.field_with(:name => 'orvName').value = bus_from.toutf8
  form.field_with(:name => 'dnvName').value = bus_to.toutf8
  form.field_with(:name => 'hour').value = h.toutf8
  form.field_with(:name => 'minute').value = m.toutf8
  form.click_button
}
 
puts "<table>"
# puts agent.page.css("#result_area_table") 
#agent.page.search("table[@class='result_area_table']").each do |elem|
elem = agent.page.at("[@class='result_area_table']")
text = elem.inner_html
#time_elem = agent.page.search("tr[@class='result_area_tr']")
time_elem = elem.search("tr[@class='result_area_tr']")
time = time_elem.pop.at('td').inner_text
time = time.sub("着","")
puts text
puts "</table>"
date = Time.strptime(time,"%H:%M")
date = date + 10*60
#puts date.strftime("%H:%M")
hh = date.strftime("%H")
mm = date.strftime("%M")
m1 = mm[0..1] 
m2 = mm[1..2] 

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
text = elem.inner_html
puts text
