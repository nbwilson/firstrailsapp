class PagesController < ApplicationController

    PAGES_PERMS_URL = "https://graph.facebook.com/me/accounts"
    LIST_PAGES_PARAMS = {access_token: ENV['ACCESS_TOKEN']}

    def index
        uri = URI(PAGES_PERMS_URL)
        uri.query = URI.encode_www_form(LIST_PAGES_PARAMS)
        response = Net::HTTP.get_response(uri)
        @data = render_get_posts_response(response)
    end

    private

    def res_body(res)
        @res ||= MultiJson.load(res.body)
    end

    def render_get_posts_response(res)
        res_body(res)["data"]
    end

end
