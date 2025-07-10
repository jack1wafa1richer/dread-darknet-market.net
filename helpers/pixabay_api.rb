require 'httparty'
require 'mini_magick'
require 'fileutils'

class PixabayAPI
  include HTTParty

  base_uri 'https://pixabay.com/api/'

  # Устанавливаем API ключ по умолчанию
  API_KEY = '44235056-7944b18f48d73b3e86dcbff3f'

  # Метод для поиска изображений
  def self.search_images(query, options = {})
    per_page = options[:per_page] || 15
    page = options[:page] || 1

    response = get("/?key=#{API_KEY}&q=#{query}&per_page=#{per_page}&page=#{page}")
    return response['hits']
  end

  # Метод для сохранения изображений и конвертации их в формат WebP
  def self.save_and_convert_images(images, output_dir, offset = 0)
    FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)

    images.each_with_index do |image, index|
      image_url = image['largeImageURL']
      image_path = "#{output_dir}/image_#{index + offset}.jpg"

      # Скачиваем изображение
      File.write(image_path, HTTParty.get(image_url).body)

      # Конвертируем изображение в формат WebP
      webp_path = "#{output_dir}/image_#{index + offset}.webp"
      MiniMagick::Tool::Convert.new do |convert|
        convert << image_path
        convert << webp_path
      end

      # Удаляем оригинальное изображение, если нужно
      File.delete(image_path) if File.exist?(image_path)
    end
  end
end
