#!/usr/bin/env ruby

require 'json/pure'
require 'net/http'
require 'i18n'
require 'date'

I18n.config.available_locales = :en

# vstup lokality

puts "Zadaj mesto: "
mesto = I18n.transliterate(gets)
if mesto.strip.to_s.empty?
  abort "Nič si nezadal."
end  

# lokalita => koordinaty
baseurl = "http://api.openweathermap.org/geo/1.0/direct?q=" + (mesto.gsub(/ /, '+')).gsub!(/\s/, '') + "&appid=3c00707c384ed93b2f0f5171531610a0".to_s

geojsondata = JSON.parse(Net::HTTP.get(URI(baseurl)))

if geojsondata.empty?
  abort "Neznáma lokalita."
end

lat = geojsondata[0]['lat'].to_s
lon = geojsondata[0]['lon'].to_s

# pocasie z koordinatov

weatherurl = "https://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&lang=sk&appid=3c00707c384ed93b2f0f5171531610a0"

wtrjsondata = JSON.parse(Net::HTTP.get(URI(weatherurl)))

temp = (wtrjsondata['main']['temp'] - 273.15).round(2).to_s
feelslike = (wtrjsondata['main']['feels_like'] - 273.15).round(2).to_s
name = wtrjsondata['name']
oblacnost = wtrjsondata['clouds']['all']
vychod_slnka = Time.at(wtrjsondata['sys']['sunrise'])
zapad_slnka = Time.at(wtrjsondata['sys']['sunset'])

if vychod_slnka.min < 10
  filler_vychod = "0"
else
  filler_vychod = ""
end

if zapad_slnka.min < 10
  filler_zapad = "0"
else
  filler_zapad = ""
end

case
when oblacnost < 20
  obl_slovo = " je takmer jasno."
  obl_symbol = "☼"
when oblacnost > 20 && oblacnost < 80
  obl_slovo = " je oblačno."
  obl_symbol = "☼☁"
else
  obl_slovo = " je zamračené."
  obl_symbol = "☁"
end

puts "Teplota v meste " + name + " je " + temp + "°C, pocitovo je to " + feelslike + "°C a" + obl_slovo + " " + obl_symbol + "\n"
puts "Slniečko vstane v " + vychod_slnka.hour.to_s + ":" + filler_vychod + vychod_slnka.min.to_s + " a zapadne v " + zapad_slnka.hour.to_s + ":" + filler_zapad + zapad_slnka.min.to_s + " vášho času.\n"
