class Dailymotion
  attr_accessor :provider, :title, :description, :duration, :publication, :uploaded, 
                :thumbs, :author, :average, :raters, :views, :url, :embed, 
                :openURI_options

  def initialize(url, options = {})
    @iframe_attributes = VideoInfo.hash_to_attributes options.delete(:iframe_attributes) if options[:iframe_attributes]    
    @openURI_options = options
    video_id_for(url)
    get_info unless @video_id == url || @video_id.nil? || @video_id.empty?
  end

  def regex
    /(?:\/video\/|\/Dailymotion#video=)([^_]+)(.*)$/
  end

  def video_id_for(url)
    url.gsub(regex) do
      @video_id = $1
    end
  end

private
	def get_info
		begin
	    datas                     = open("https://api.dailymotion.com/video/#{@video_id}/?fields=title,description,duration,modified_time,created_time,thumbnail_small_url,thumbnail_medium_url,thumbnail_large_url,owner.screenname,rating,ratings_total,views_total,allow_embed,embed_html,embed_url").read
	    datas                     = JSON.parse(datas)
	    @provider                 = "Dailymotion"
	    
	    # Video       
	    @title                    = datas["title"]
	    @description              = datas["description"].html_safe
	    @duration                 = datas["duration"]
	    @publication              = datas["created_time"]
	    @updated                  = datas["modified_time"]
	      
	    # Thumbs        
	    @thumbs                   = HashWithIndifferentAccess.new
	    @thumbs[:small]           = datas["thumbnail_small_url"]
	    @thumbs[:medium]          = datas["thumbnail_medium_url"]
	    @thumbs[:large]           = datas["thumbnail_large_url"]

	    # Author
	    @author                   = HashWithIndifferentAccess.new
	    @author[:name]            = datas["owner.screenname"]
	    @author[:uri]             = "http://dailymotion.com/user/#{@author[:name]}"

	    # Statistiques
	    @average                  = datas["rating"]
	    @raters                   = datas["ratings_total"]
	    @views                    = datas["views_total"]

	    # Useful
	    @url                      = HashWithIndifferentAccess.new
	    @url[:default]            = "http://www.dailymotion.com/video/#{@video_id}"
	    @url[:embed]              = datas["embed_url"]
	    @embed                    = datas["embed_html"].html_safe
	  rescue
	    nil
	  end
	end
end