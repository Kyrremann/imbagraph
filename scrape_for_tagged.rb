require 'open-uri'
require 'nokogiri'

require_relative 'models/init'

def get_doc(url)
  begin
    doc = open(url)
  rescue OpenURI::HTTPError => e
    response = e.io
    p e
    exit if response.status[0] == "429"
  end
  Nokogiri::HTML(doc)
end

def extract_tagged(doc)
  tagged = []
  doc.css(".tagged-friends").css("ul").css("li").css("a").each do |a|
    tagged.append(a.values[0].split('/')[2])
  end

  return tagged.flatten
end

def retrieve_new_tagged
  checkins = Checkin.where(:parsed_tagged => false).first(15)
  checkins.each do |checkin|
    next if checkin.parsed_tagged
    p checkin.checked_in
    doc = get_doc(checkin.untappd_url)
    tagged = extract_tagged(doc)
    p tagged
    tagged.each do |username|
      tagged_user = User.find(:username => username)
      tagged_user = User.create(:username => username) unless tagged_user
      Tagged.create(:user_id => checkin.user_id,
                    :tagged_user_id => tagged_user.id,
                    :checkin_id => checkin.id)
    end
    checkin.parsed_tagged = true
    checkin.save
    sleep(1)
  end
end

retrieve_new_tagged
