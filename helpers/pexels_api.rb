require 'httparty'
require 'mini_magick'

class PexelsAPI
  include HTTParty

  base_uri 'https://api.pexels.com/v1'

  # Устанавливаем API ключ по умолчанию
  API_KEY = 'izuIbmYLZXpIDkie1P7cFjDXecNjw1gex1qFZalKP3ATv1EzUQHrcgnM'

  # Метод для поиска фотографий
  def self.search_photos(query, options = {})
    per_page = options[:per_page] || 15
    page = options[:page] || 1

    headers = { 'Authorization' => "Bearer #{API_KEY.strip}" }
    response = get("/v1/search", query: { query: query, per_page: per_page, page: page }, headers: headers)

    puts "Response Code: #{response.code}" # Отладочный вывод
    puts "Response Message: #{response.message}" # Отладочный вывод
    puts "Response Body: #{response.body}" # Отладочный вывод

    # Проверяем, успешно ли выполнен запрос
    if response.code == 200
      return response['photos']
    else
      # В случае ошибки, можно вернуть nil или сгенерировать исключение
      raise "Ошибка при запросе к API Pexels: #{response.code} - #{response['error']}"
    end
  end

  # Метод для сохранения изображений и конвертации их в формат WebP
  def self.save_and_convert_images(images, output_dir)
    images.each_with_index do |image, index|
      image_url = image['src']['original']
      image_path = "#{output_dir}/image_#{index}.jpg"

      # Скачиваем изображение
      File.write(image_path, HTTParty.get(image_url).body)

      # Конвертируем изображение в формат WebP
      MiniMagick::Tool::Convert.new do |convert|
        convert << image_path
        convert.webp "#{output_dir}/image_#{index}.webp"
      end
    end
  end
end
