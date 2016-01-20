class PostsController < ApplicationController
    before_action :set_page
    
    def index
        uri = params['id'].blank? ? unpaginated_index_params : paginated_index_params
        response = Net::HTTP.get_response(uri)
        @data = render_get_posts_response(response)
        if !res_body(response)["paging"].nil?
            @next_page = res_body(response)["paging"]["next"] 
            @prev_page = res_body(response)["paging"]["previous"]
        else
            @back_page = params[:from]
        end
    end

    def create
        uri = URI("https://graph.facebook.com/#{$PAGE_ID}/feed")
        res = Net::HTTP.post_form(uri, create_post_params)
        redirect_to action: "index"
    end

    def show
        uri = URI("https://graph.facebook.com/#{params[:id]}/insights")
        uri.query = URI.encode_www_form({access_token: $PAGE_ACCESS_TOKEN})
        res = Net::HTTP.get_response(uri)
        @data = render_get_posts_response(res)
    end

    private

    def list_posts_params
        {access_token: $PAGE_ACCESS_TOKEN, fields: 'insights{name,values},is_hidden,id,message,from,to,link,is_published,scheduled_publish_time', include_hidden: "true", limit: "10"}
    end

    def set_page
        $PAGE_ID = params[:page_id] if params[:page_id]
        $PAGE_ACCESS_TOKEN = params[:access_token] if params[:access_token]
    end

    def unpaginated_index_params
        uri = URI("https://graph.facebook.com/#{$PAGE_ID}/promotable_posts")
        uri.query = URI.encode_www_form(list_posts_params)
        uri
    end

    def paginated_index_params
        URI(params['id'])
    end

    def res_body(res)
        @res ||= MultiJson.load(res.body)
    end

    def render_get_posts_response(res)
        res_body(res)["data"]
    end

    def time_from_form
        Time.new(params[:posts][:'scheduled_time(1i)'], params[:posts][:'scheduled_time(2i)'], params[:posts][:'scheduled_time(3i)'], params[:posts][:'scheduled_time(4i)'], params[:posts][:'scheduled_time(5i)'], params[:posts][:'scheduled_time(6i)'], ActiveSupport::TimeZone.new(params[:posts][:time_zone]).formatted_offset).to_i
    end

    def post_params
        params.require(:posts).permit(:link, :message, :time, :publish)
    end

    def published?
        params[:posts][:publish] == "1"
    end

    def create_post_params
        create_post_params = {access_token: $PAGE_ACCESS_TOKEN}
        create_post_params[:link] = params[:posts][:link] unless params[:posts][:link].blank?
        create_post_params[:message] = params[:posts][:message] unless params[:posts][:message].blank?
        create_post_params[:scheduled_publish_time] = time_from_form if params[:posts][:schedule] == "1"
        create_post_params[:published] = published?.to_s unless published?
        create_post_params
    end

end
