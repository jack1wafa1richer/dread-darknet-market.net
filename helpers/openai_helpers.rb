require 'yaml'
require 'httparty'
require 'fileutils'
require 'time'
require_relative 'ai_common'

module OpenAIHelpers
  def self.gpt3_rewrite(prompt, lang, theme)
    api_key = "sk-proj-8qd1HTrMecBl4utGQK5mT3BlbkFJujvhCvsXaYH2Mj1lLLV4"  # Замените на ваш реальный API ключ
    model = "gpt-4o"

    # Формируем полный текстовый промпт, включая тематику
    full_prompt = AICommon.generate_full_prompt(prompt, lang, theme)

    messages = [
      { role: "system", content: "You are a helpful assistant that generates YAML content based on the provided prompt. The content should be written in #{lang}." },
      { role: "user", content: "Please generate YAML content based on the following prompt while adhering to the structure and instructions:\n\n#{full_prompt}" }
    ]

    puts "Sending request to GPT-3 with messages: #{messages}"

    response = HTTParty.post(
      "https://api.openai.com/v1/chat/completions",
      headers: {
        "Authorization" => "Bearer #{api_key}",
        "Content-Type" => "application/json"
      },
      body: {
        model: model,
        messages: messages,
        temperature: 0.7,
        max_tokens: 4096,
        top_p: 0.9,
        frequency_penalty: 0.2,
        presence_penalty: 0.2
      }.to_json
    )

    if response.code == 200
      rewritten_content = response.parsed_response['choices'].first['message']['content']
      puts "GPT-3 response: #{rewritten_content}"
      rewritten_content.strip
    else
      puts "Ошибка при обращении к OpenAI API: #{response.code} #{response.message}".red
      raise "OpenAI API error"
    end
  rescue => e
    puts "Ошибка при рерайте текста: #{e.message}".red
    raise e
  end

  def self.generate_content_from_prompt(prompt_file, output_file, lang, theme)
    puts "Чтение файла prompt.yml".blue
    prompt = File.read(prompt_file)

    puts "Генерация контента с помощью GPT-3".blue
    generated_content = gpt3_rewrite(prompt, lang, theme)

    # Удаляем ненужные символы
    cleaned_content = AICommon.clean_generated_content(generated_content)

    puts "Запись сгенерированного контента в #{output_file}".blue
    File.open(output_file, 'w') { |file| file.write(cleaned_content) }

    puts "Генерация контента завершена".green
  end
end
