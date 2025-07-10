require 'yaml'

def load_yaml_file(file_path)
  begin
    content = File.read(file_path, encoding: 'UTF-8')
    puts "#{file_path}: OK"
    YAML.safe_load(content)
  rescue => e
    puts "#{file_path}: #{e.message}"
    nil
  end
end

load_yaml_file('data/config.yml')
load_yaml_file('data/content.yml')
