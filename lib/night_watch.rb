Dir[File.join(File.dirname(__FILE__), 'night_watch', '**', '*.rb')].each { |file| require file }

module NightWatch
end
