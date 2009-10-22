# encoding: utf-8

require 'activesupport'

module SaidFm
  module PodcastDataExtractorUtils
    SECONDS_IN_A_MINUTE = 60
    
    def collect_any_keywords_from(holder)
      result = []
      result += holder.categories.split(/,/).flatten if holder.respond_to?(:categories) && !holder.categories.nil?
      result += holder.itunes_keywords.split(/,/).flatten if holder.respond_to?(:itunes_keywords) && !holder.itunes_keywords.nil?
      result
    end

    def tagify(values=[])
      values.collect do |value|
        value.gsub!('.', '_')
        if value.include?(' ')
          value.split(' ').collect{|w| w.capitalize}.join.underscore
        else
          value.underscore
        end
      end
    end

    def determine_duration_from(entry)
      unless entry.itunes_duration.nil?
        prepared_for_parsing = entry.itunes_duration.split(/:/).size == 2 ? "00:#{entry.itunes_duration}" : entry.itunes_duration
        return Time.parse(prepared_for_parsing).min 
      end
      return (entry.media_duration.to_i / SECONDS_IN_A_MINUTE) unless entry.media_duration.nil?
      return 0
    end
  end
end