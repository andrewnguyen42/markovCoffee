require "#{Rails.root}/lib/markov/MarkovChain.rb"
require "#{Rails.root}/lib/markov/MarkovChainWord.rb"

require 'open-uri'

class MarkovController < ApplicationController

  def index

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
    doc.css('script').remove
    doc.css('head').remove
    doc.css('table').remove
    doc.css('style').remove
    doc.css('br').remove
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
    doc.css('.reflist').remove
    doc.css('.printfooter').remove
    doc.css('.dablink').remove
    doc.css('.rellink').remove

    

    doc.xpath("//@*[starts-with(name(),'on')]").remove
    final_text=ActionView::Base.full_sanitizer.sanitize(doc.to_s).gsub(/<!.*?$/,'')
    .gsub(/\n/,' ').gsub(/\t/,' ').gsub('(','').gsub(')','')
 

    m=MarkovChainWord.new(final_text,3)
    m.generate(len)

    render :text => m.to_string.humanize, :content_type => 'text/plain'

  end
end
