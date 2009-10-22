# encoding: utf-8

require 'activesupport'

module SaidFm
  module PodcastDataExtractorUtils
    SECONDS_IN_A_MINUTE = 60
    MINUTES_IN_AN_HOUR = 60
    
    def collect_any_keywords_from(holder)
      result = []
      result += holder.categories.split(/,/) if holder.respond_to?(:categories) && !holder.categories.nil?
      result += holder.itunes_keywords.split(/,/) if holder.respond_to?(:itunes_keywords) && !holder.itunes_keywords.nil?
      result.compact.flatten.delete_if{ |e| e == "" }
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
        parts = entry.itunes_duration.split(/:/)
        hours = (parts.size == 2 ? 0 : parts[0]).to_i
        minutes = (parts.size == 2 ? parts[0] : parts[1]).to_i
        calculated_duration = (hours * MINUTES_IN_AN_HOUR) + minutes
        return calculated_duration
      end
      unless entry.media_duration.nil?
        calculated_duration = (entry.media_duration.to_i / SECONDS_IN_A_MINUTE) 
        return calculated_duration
      end
      return 0
    end
  end
end