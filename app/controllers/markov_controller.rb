require "#{Rails.root}/lib/markov/MarkovChain.rb"
require "#{Rails.root}/lib/markov/MarkovChainWord.rb"

require 'open-uri'

class MarkovController < ApplicationController

  def index

  end

  def conf

    term= params[:term].nil?||params[:term].empty? ? 'Business' : params[:term]
    len= params[:len].nil?||params[:len].empty? ? 10 : params[:len]

    begin
        html = open("http://www.conferencealerts.com/topic-listing.php?page=1&ipp=All&topic="+URI.escape(term))
    rescue OpenURI::HTTPError => ex
        html = open("http://www.conferencealerts.com/topic-listing.php?page=1&ipp=All&topic=Business")
    end

    doc = Nokogiri.HTML(html)
    doc.css('#loginDivContainer').remove
    doc.css('#searchBoxTable').remove
    doc.css('#homeLink').remove
    doc.css('.paginate').remove
    doc.css('.current').remove


    conferences=''
    doc.search('a').map do |n|
      conferences+= n.text+' '
    end    
    conferences=conferences.gsub(/\(.*?\)/, "")
    .gsub('/',' ').gsub('-',' ').gsub('.',' ').gsub(':',' ').gsub('2014','').gsub('2015','')
   
    m=MarkovChainWord.new(conferences,2)
    m.generate(len)
    final_text=m.to_string.humanize.strip!

    bad_endings=["on","or","of","and","in","the","&","and"]

    if bad_endings.include? final_text.split.last
        final_text=final_text[0...final_text.rindex(' ')]
    end

    render :text => final_text, :content_type => 'text/plain'

    #render :text => conferences , :content_type => 'text/plain'
  end



  def generate

  	term= params[:term].nil?||params[:term].empty? ? 'Productivity' : params[:term]
  	len= params[:len].nil?||params[:len].empty? ? 10 : params[:len]

  	begin
    	html = open("http://en.wikipedia.org/wiki/"+URI.escape(term.downcase))
    rescue OpenURI::HTTPError => ex
    	html = open("http://en.wikipedia.org/wiki/productivity")
    end

    doc = Nokogiri.HTML(html)

    #strip out wikipedia crap
    doc.css('script').remove
    doc.css('head').remove
    doc.css('table').remove
    doc.css('style').remove
    doc.css('br').remove
    doc.css('h2').remove
    doc.css('p').remove
    doc.css('sup').remove
    doc.css('span').remove
    doc.css('#mw-panel').remove
    doc.css('#footer').remove
    doc.css('#mw-navigation').remove
    doc.css('#jump-to-nav').remove
    doc.css('#siteSub').remove
    doc.css('#mw-navigation').remove
    doc.css('#catlinks').remove
    doc.css('#External_links').remove
    doc.css('.reflist').remove
    doc.css('.printfooter').remove
    doc.css('.dablink').remove
    doc.css('.rellink').remove
    doc.xpath("//@*[starts-with(name(),'on')]").remove
    final_text=ActionView::Base.full_sanitizer.sanitize(doc.to_s).gsub(/<!.*?$/,'')
    .gsub(/\n/,' ').gsub(/\t/,' ').gsub('(','').gsub(')','').gsub('–',' ').gsub('.',' ')
    .gsub(' "',' ').gsub('" ',' ')
 
    real_text="2014 1st International Conference on Business Management, Economics, Tourism and Technology Management"

    m=MarkovChainWord.new(final_text,3)
    m.generate(len)

    render :text => m.to_string.humanize, :content_type => 'text/plain'

  end
end
