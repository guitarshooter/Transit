# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'kconv'
require 'date'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'json'

helpers do
  include Rack::Utils; alias_method :h, :escape_html
end

get '/' do
  haml :index
end

get '/bus' do
  busurl = 'http://transfer.navitime.biz/bus-navi/pc/transfer/TransferTop'
  trainurl = 'http://transit.loco.yahoo.co.jp'
  bus_from = '宇津木台中央'
  bus_to = '日野駅'
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

  content_type :json
  { :deptime => @bus_deptime, :arrtime => @bus_arrtime ,:fare => @bus_fare}.to_json

end

get '/train' do 

  trainurl = 'http://transit.loco.yahoo.co.jp'
  train_from = '日野(東京都)'
  train_to = params[:to]
  hh = params[:h]
  mm = params[:m]
  m1 = mm[0..0] 
  m2 = mm[1..1] 

  agent = Mechanize::new

  agent.get(trainurl)

  agent.page.form_with(:name => 'search'){|form|
    form.field_with(:name => 'from').value = train_from.toutf8
    form.field_with(:name => 'to').value = train_to.toutf8
    form.field_with(:name => 'hh').value = hh.toutf8
    form.field_with(:name => 'm1').value = m1.toutf8
    form.field_with(:name => 'm2').value = m2.toutf8
    form.click_button
  }
  elem = agent.page.at("[@class='route-departure']")
  #puts agent.page.at("[@class='route-head']")
  @train_depttime = elem.inner_text
  p @train_depttime
  elem2 = agent.page.at("[@class='route-arrive-on']")
  @train_arrtime = elem2.inner_text
  p @train_arrtime
  elem3 = agent.page.at("[@class='time']")
  @train_time = elem3.at('dd').inner_text
  p @train_time
  elem4 = agent.page.at("[@class='route-fare-on']")
  @train_fare = elem4.inner_text
  p @train_fare
  #haml :result
end
