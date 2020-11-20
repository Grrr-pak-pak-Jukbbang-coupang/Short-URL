class ShortenedUrl < ApplicationRecord
    UNIQUE_ID_LENGTH = 6
    #validates는 정확한 데이터를 데이터베이스에 저장하기 위해 사용 
    #original_url이 입력이 안되면 데이터베이스에 저장이 안됨   
    validates :original_url, presence: true, on: :create 

    validates_format_of :original_url, 
     with: /\A(?:(?:http|https):\/\/)?([-a-zA-Z0-9.]{2,256}\.[a-z]{2,4})\b(?:\/[-a-zA-Z0-9@,!:%_\+.~#?&\/\/=]*)?\z/
    before_create :generate_short_url
    before_create :sanitize

    def generate_short_url
        url =([*('a'..'z'),*('0'..'9')]).sample(UNIQUE_ID_LENGTH).join
        old_url = ShortenedUrl.where(short_url: url).last # where은 조건이고 .last는 주어진 조건과 일치하는 마지막 레코드를 찾음
        if old_url.present? # blank랑 반대 blank는 안에 없어야하는데 present는 있어야 참
            self.generate_short_url
        else
            self.short_url = url
        end
    end

    def find_duplicate
        ShortenedUrl.find_by_sanitize_url self.sanitize_url
    end

    def new_url?
        find_duplicate.nil?
    end

    def sanitize
        self.original_url.strip! #   
        self.sanitize_url = self.original_url.downcase.gsub(/(https?:\/\/)|(www\.)/, "")
        self.sanitize_url = "http://#{self.sanitize_url}" #original url을 저장 
    end

end
