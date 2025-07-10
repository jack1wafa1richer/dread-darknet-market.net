require 'yaml'
require 'fileutils'
require 'time'

module CustomHelpers
  def current_theme
    data.config.html_theme
  end

  def section_partial(section_name)
    theme = current_theme
    section_number = data.config.sections[section_name]
    "sections/#{theme}/#{section_name}/#{section_name}-#{section_number}"
  end

  def current_shop
    data.config.general.shop
  end

  def random_image_path
    shop_name = current_shop
    image_directory = "source/images/shops/#{shop_name}"
    image_files = Dir.glob("#{image_directory}/*-small.webp")

    if image_files.empty?
      raise "No images found in #{image_directory}"
    end

    image_files.sample.gsub("source/", "")
  end

  def generate_srcset(image_path)
    base_name = File.basename(image_path, "-small.webp")
    image_directory = File.dirname(image_path)
    srcset = []

    { small: 320, medium: 640, large: 1280 }.each do |size_name, size_width|
      srcset << "#{image_directory}/#{base_name}-#{size_name}.webp #{size_width}w"
    end

    srcset.join(", ")
  end

  def image_tag_with_srcset(opts = {})
    image_path = random_image_path
    srcset = generate_srcset(image_path)
    tag(:img, { src: image_path, srcset: srcset, sizes: "100vw" }.merge(opts))
  end

  def self.process_content(content_file)
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    backup_file = "#{content_file}.#{timestamp}.bak"
    puts "Создание бэкапа файла #{content_file} в #{backup_file}"
    FileUtils.cp(content_file, backup_file)

    puts "Чтение файла #{content_file}"
    content = File.read(content_file)

    puts "Замена ключевых слов"
    replaced_content = self.replace_keywords(content)

    puts "Запись обновленного контента в #{content_file}"
    File.open(content_file, 'w') { |file| file.write(replaced_content) }

    puts "Обработка контента завершена"
  end

  def self.replace_keywords(content)
    config = YAML.load_file('data/config.yml')
    keyword1_values = config['keyword_1']
    keyword2_values = config['keyword_2']

    # Используем регулярное выражение для поиска и замены макросов с оборачиванием в <strong> теги
    content = content.gsub('{{keyword1}}') { "<strong>#{keyword1_values.sample}</strong>" }
    content = content.gsub('{{keyword2}}') { "<strong>#{keyword2_values.sample}</strong>" }

    content
  end
end
