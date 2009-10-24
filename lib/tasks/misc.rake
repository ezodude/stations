task :default => [:init_test_env] do
  Dir["test/**/*.rb"].sort.each { |test| load test }
  ENV['RUNNING_CONTEXT'] = 'development'
end

namespace :saidfm do
  task :collect_programmes => [:init_env] do
    collector = PodcastCollector.new(FEEDS)
    collector.collect_podcasts
  
    puts ">>>Summary of collected programmes on #{Time.now.utc}<<<"
    collector.collected_podcasts.each do |feed_uri, podcasts|
      puts " Feed [#{feed_uri}] #{podcasts.size == 0 ? 'No new content found for this feed' : ''}"
      podcasts.each do |p|
        puts "  title: [#{p.title}], duration: [#{p.duration.to_s}], published on: [#{p.published_at}], source uri: [#{p.source_uri}]]"
        puts "  audio uri: [#{p.audio_uri}]"
        puts "  ----"
      end
      puts "---------------------------------------"
    end
  
    collector = nil
  end
end