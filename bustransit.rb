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
 
bus_elem = agent.page.at("[@class='result_area_table']")
@bus_text = bus_elem.inner_html
@bus_time = @bus_text.scan(/(\d+):(\d+)/)
@bus_fare =  @bus_text.scan(/(\d+円)/)
@bus_fare = @bus_fare[0][0] #料金
@bus_deptime = @bus_time[0].join(':') #出発時刻
@bus_arrtime = @bus_time[1].join(':') #到着時刻

busstat_elem = bus_elem.search("table[@class='result_area_section_table']")
@bus_status = busstat_elem.pop.at('td').inner_html
@bus_status.gsub!(/[\r\n\t]/,"") #バスの行き先＆現在位置のjavascript
p @bus_status

@bus_text = "<table>" + @bus_text + "</table>"
@bus_text = @bus_text.sub(' width="60"',' width="75"') #時間
@bus_text = @bus_text.sub(' width="335"',' width="300"')
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
@routehead = @routehead.sub(/<ul class="service">.*<\/ul>/m,"")
#@infomation = '<div class="route-head">' + @routehead +  @infomation + '</div>'
@infomation = '<div class="route-head">' + @routehead + '</div>'

#train_text = bus_text + '<div class="route">' + train_text + '</div>'
@train_text = @infomation + '<div class="route">' + @train_text + '</div>'
#train_text
haml :result
end
