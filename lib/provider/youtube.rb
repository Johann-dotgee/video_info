class Youtube

  attr_accessor :provider, :title, :description, :duration, :publication, :uploaded, 
                :category_title, :category_detail, :thumbs, :author, 
                :average, :likes, :dislikes, :raters, :favorite, :views,
                :url, :embed, :openURI_options



  def initialize(url, options = {})
    @iframe_attributes = VideoInfo.hash_to_attributes options.delete(:iframe_attributes) if options[:iframe_attributes]    
    @openURI_options = options
    video_id_for(url)
    get_info unless @video_id == url || @video_id.nil? || @video_id.empty?
  end

  def regex
    /youtu(.be)?(be.com)?.*(?:\/|v=)([\w-]+)/
  end

  def video_id_for(url)
    url.gsub(regex) do
      @video_id = $3
    end
  end

private

  def get_info
    begin
      datas                     = open("http://gdata.youtube.com/feeds/api/videos/#{@video_id}?v=2&alt=json").read
      datas                     = JSON.parse(datas)
      @provider                 = "Youtube"
      
      # Video       
      @title                    = datas["entry"]["title"]
      @description              = datas["entry"]["media$group"]["media$description"]["$t"].html_safe
      @duration                 = datas["entry"]["media$group"]["yt$duration"]["seconds"]
      @publication              = datas["entry"]["published"]["$t"].to_date.strftime("%d %B %Y")
      @updated                  = datas["entry"]["updated"]["$t"].to_date.strftime("%d %B %Y")
        
      #Catégorie        
      @category_title           = datas["entry"]["category"][1]["term"]
      @category_detail          = datas["entry"]["category"][1]["label"]
        
      # Thumbs        
      @thumbs                   = HashWithIndifferentAccess.new
      @thumbs[:small]           = HashWithIndifferentAccess.new
      @thumbs[:small][:default] = datas["entry"]["media$group"]["media$thumbnail"][0]
      @thumbs[:small][:start]   = datas["entry"]["media$group"]["media$thumbnail"][3]
      @thumbs[:small][:middle]  = datas["entry"]["media$group"]["media$thumbnail"][4]
      @thumbs[:small][:end]     = datas["entry"]["media$group"]["media$thumbnail"][5]
      @thumbs[:medium]          = datas["entry"]["media$group"]["media$thumbnail"][1]
      @thumbs[:large]           = datas["entry"]["media$group"]["media$thumbnail"][2]

      # Author
      @author                   = HashWithIndifferentAccess.new
      @author[:name]            = datas["entry"]["author"]["name"]["$t"]
      @author[:uri]             = datas["entry"]["author"]["uri"]["$t"]
      @author[:id]              = datas["entry"]["author"]["yt$userId"]["$t"]

      # Statistiques
      @average                  = datas["entry"]["gd$rating"]["average"]
      @dislikes                 = datas["entry"]["yt$rating"]["numDislikes"]
      @likes                    = datas["entry"]["yt$rating"]["numLikes"]
      @raters                   = datas["entry"]["gd$rating"]["numRaters"]
      @favorite                 = datas["entry"]["yt$statistics"]["favoriteCount"]
      @views                    = datas["entry"]["yt$statistics"]["viewCount"]

      # Useful
      @url                      = HashWithIndifferentAccess.new
      @url[:default]            = "http://www.youtube.com/watch?v=#{@video_id}"
      @url[:embed]              = "http://www.youtube.com/embed/#{@video_id}"
      @embed                    = "<iframe src=\"#{@url[:embed]}\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"#{@iframe_attributes}></iframe>".html_safe
    rescue
      nil
    end
  end

end
