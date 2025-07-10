module UnsplashAPI
  include HTTParty
  base_uri 'https://api.unsplash.com'

  def self.random_image(keyword)
    response = get("/photos/random", query: { client_id: 'pev3O7vBoENcwaBPMpGdbzSxjX9xexM3ocS-AqWxFfQ', query: keyword })
    if response.success?
      image_data = JSON.parse(response.body)
      return image_data['urls']['regular']
    else
      # Обработка ошибок, если запрос не удался
      puts "Ошибка при получении изображения: #{response.code} - #{response.message}"
      return nil
    end
  end
end
