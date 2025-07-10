require 'yaml'
require 'httparty'
require 'fileutils'
require 'time'
require_relative 'ai_common'

module ClaudeHelpers
  MAX_RETRIES = 3
  RETRY_DELAY = 5 # секунд

  def self.claude_rewrite(prompt, lang, theme)
    api_key = ENV['CLAUDE_API_KEY']
    if api_key.nil? || api_key.empty?
      puts "Ошибка: API ключ Claude не установлен. Установите переменную окружения CLAUDE_API_KEY.".red
      raise "Claude API key not set"
    end

    url = "https://api.anthropic.com/v1/messages"
    headers = {
      "x-api-key" => api_key,
      "Content-Type" => "application/json",
      "anthropic-version" => "2023-06-01"
    }

    full_prompt = AICommon.generate_full_prompt(prompt, lang, theme)

    body = {
      "model" => "claude-3-haiku-20240307",
      "max_tokens" => 4000,
      "messages" => [
        {"role" => "user", "content" => full_prompt}
      ]
    }

    retries = 0
    loop do
      begin
        puts "Отправка запроса к Claude API... (Попытка #{retries + 1}/#{MAX_RETRIES})"
        puts "URL: #{url}"
        puts "Заголовки: #{headers}"
        puts "Тело запроса: #{body.to_json}"

        response = HTTParty.post(
          url,
          headers: headers,
          body: body.to_json
        )

        if response.code == 200
          rewritten_content = response.parsed_response['content'][0]['text']
          puts "Claude response received successfully.".green
          return rewritten_content.strip
        elsif response.code == 429 || response.code == 529 # Rate limit or API Overload
          raise "API Overload or Rate Limit"
        else
          puts "Ошибка при обращении к Claude API: #{response.code} #{response.message}".red
          puts "Тело ответа: #{response.body}"
          raise "Claude API error: #{response.message}"
        end
      rescue => e
        puts "Ошибка: #{e.message}".red
        if retries < MAX_RETRIES - 1
          retries += 1
          puts "Повторная попытка через #{RETRY_DELAY} секунд...".yellow
          sleep(RETRY_DELAY)
        else
          puts "Превышено максимальное количество попыток. API Claude недоступен.".red
          puts "Пожалуйста, попробуйте снова через несколько минут."
          raise "Claude API unavailable after #{MAX_RETRIES} attempts"
        end
      end
    end
  end

  def self.generate_content_from_prompt(prompt_file, output_file, lang, theme)
    puts "Чтение файла prompt.yml".blue
    prompt = File.read(prompt_file)

    puts "Генерация контента с помощью Claude".blue
    generated_content = claude_rewrite(prompt, lang, theme)

    if generated_content
      cleaned_content = AICommon.clean_generated_content(generated_content)

      puts "Запись сгенерированного контента в #{output_file}".blue
      File.open(output_file, 'w') { |file| file.write(cleaned_content) }

      puts "Генерация контента завершена".green
    else
      puts "Не удалось сгенерировать контент. Пожалуйста, попробуйте позже.".red
    end
  end
end
