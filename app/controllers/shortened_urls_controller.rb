class ShortenedUrlsController < ApplicationController
    
    before_action :find_url, only: [:show, :shortened]

    def index
        @urls = ShortenedUrl.new
        @urls = ShortenedUrl.page(params[:page]).per(5)
    end

    def show
        redirect_to @url.sanitize_url
    end

    def create
        @url = ShortenedUrl.new
        @url.original_url = params[:original_url] 
        @url.sanitize
        if @url.new_url? #new url이 새로운 url이냐 맞으면 if문으로 내려가서 그 url을 저장
            if @url.save
                redirect_to shortened_path(@url.short_url)
            else    
                flash[:error] = "Check the error below :"
                render 'index'
            end
        else
            flash[:notice] = "A short link for this URL is already in out database"
            redirect_to shortened_path(@url.find_duplicate.short_url)
        end
    end

    def shortened
        @url = ShortenedUrl.find_by_short_url(params[:short_url])
        host = request.host_with_port #호스트 이름 가져오기
        @original_url = @url.sanitize_url #original url 한마디로 내가 입력한 긴주소
        @short_url = [host, @url.short_url].join "/" #호스트명/단축된url
    end

    def fetch_original_url
        fetch_url = ShortenedUrl.find_by_short_url(params[:short_url])
        redirect_to fetch_url.sanitize_url
    end

    private 
    def find_url
        @url = ShortenedUrl.find_by_short_url(params[:short_url])
    end

    def url_params
        params.require(:url).permit(:original_url)
    end
end
