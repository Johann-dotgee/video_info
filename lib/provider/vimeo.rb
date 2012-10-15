class Vimeo
  attr_accessor :provider, :title, :description, :duration, :uploaded, 
                :thumbs, :author, :likes, :url, :embed, :publication,
                :openURI_options

  def initialize(url, options = {})
    @iframe_attributes = VideoInfo.hash_to_attributes options.delete(:iframe_attributes) if options[:iframe_attributes]
    @openURI_options = options
    @video_id = url.gsub(/.*\.com\/(?:groups\/[^\/]+\/videos\/)?([0-9]+).*$/i, '\1')
    get_info unless @video_id == url || @video_id.nil? || @video_id.empty?
  end

private

  def get_info
    begin
    #
    #
      datas                     = open("http://vimeo.com/api/v2/video/#{@video_id}.json").read
      datas                     = JSON.parse(datas)
      datas                     = datas.first
      @provider                 = "Vimeo"

      # Video
      @title                    = datas["title"]
      @description              = datas["description"].html_safe
      @duration                 = datas["duration"]
      @publication              = datas["upload_date"].to_date.strftime("%d %B %Y")

      # Thumbs
      @thumbs                   = HashWithIndifferentAccess.new
      @thumbs[:small]           = datas["thumbnail_small"]
      @thumbs[:medium]          = datas["thumbnail_medium"]
      @thumbs[:large]           = datas["thumbnail_large"]

      # Author
      @author                   = HashWithIndifferentAccess.new
      @author[:name]            = datas["user_name"]
      @author[:uri]             = datas["user_url"]
      @author[:id]              = datas["user_id"]
      @author[:thumbs]          = HashWithIndifferentAccess.new
      @author[:thumbs][:small]  = datas["user_portrait_small"]
      @author[:thumbs][:medium] = datas["user_portrait_medium"]
      @author[:thumbs][:large]  = datas["user_portrait_large"]

      # Statistiques
      @likes                    = datas["stats_number_of_likes"]

      # Useful
      @url                      = HashWithIndifferentAccess.new
      @url[:default]            = "http://www.vimeo.com/#{@video_id}"
      @url[:embed]              = "http://player.vimeo.com/video/#{@video_id}"
      @embed                    = "<iframe src=\"#{@url[:embed]}\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"#{@iframe_attributes}></iframe>".html_safe
    rescue
      nil
    end
  end

end
