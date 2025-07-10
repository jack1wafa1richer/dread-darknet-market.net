if defined?(Encoding)
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

require 'rake'
require 'fileutils'
require 'yaml'
require 'mini_magick'
require 'colorize'
require_relative './helpers/pixabay_api'
require_relative './helpers/custom_helpers'
require_relative './helpers/openai_helpers'
require_relative './helpers/claude_helpers'

def ensure_utf8(file_path)
  content = File.read(file_path)
  return if content.encoding.name == 'UTF-8'

  utf8_content = content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  File.write(file_path, utf8_content)
end

namespace :images do
  desc "Загрузка и конвертация изображений из Pixabay API"
  task :download_and_convert do
    ensure_utf8('data/config.yml')

    config = YAML.load_file('data/config.yml')

    shop = config['general']['shop']
    themes = config['image_theme']
    output_dir = "source/images/shops/#{shop}"

    FileUtils.mkdir_p(output_dir)

    max_images = 100
    total_images = 0
    image_counter = 0

    themes.each do |theme|
      page = 1

      while total_images < max_images
        images = PixabayAPI.search_images(theme, per_page: 15, page: page)
        break if images.empty?

        remaining_images = max_images - total_images
        images_to_save = images.first(remaining_images)

        images_to_save.each do |image|
          image_url = image['webformatURL']
          image_path = "#{output_dir}/image_#{image_counter}.jpg"

          File.write(image_path, HTTParty.get(image_url).body, mode: 'wb')

          begin
            sizes = { small: 320, medium: 640, large: 1280 }
            sizes.each do |size_name, size_width|
              MiniMagick::Tool::Convert.new do |convert|
                convert << image_path
                convert.resize("#{size_width}x")
                convert << "#{output_dir}/image_#{image_counter}-#{size_name}.webp"
              end
            end

            FileUtils.rm(image_path)
          rescue MiniMagick::Error => e
            puts "Ошибка при конвертации #{image_path} в WebP: #{e.message}".red
          end

          image_counter += 1
          total_images += 1

          break if total_images >= max_images
        end

        puts "Загружено изображений: #{total_images} из #{max_images}".green

        page += 1
        break if total_images >= max_images
      end

      break if total_images >= max_images
    end

    puts "Загрузка и конвертация изображений завершены. Всего сохранено изображений: #{total_images}".green
  end
end

namespace :content do
  desc "Обработка контента"
  task :process do
    puts "Начало обработки контента...".blue
    CustomHelpers.process_content('data/content.yml')
    puts "Обработка контента завершена.".green
  end

  desc "Генерация контента с помощью AI"
  task :generate do
    ensure_utf8('data/config.yml')
    config = YAML.load_file('data/config.yml')
    lang = config['general']['lang']
    theme = config['general']['content_topic']

    ai_model = ENV['AI_MODEL'] || config['general']['ai_model'] || 'gpt-3.5'

    puts "Генерация контента с помощью #{ai_model} начата...".blue

    case ai_model
    when 'claude'
      ClaudeHelpers.generate_content_from_prompt('data/prompt.yml', 'data/content.yml', lang, theme)
    else # по умолчанию используем GPT-3.5
      OpenAIHelpers.generate_content_from_prompt('data/prompt.yml', 'data/content.yml', lang, theme)
    end

    puts "Генерация контента с помощью #{ai_model} завершена.".green
  end
end
