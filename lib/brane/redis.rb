require 'digest'
require 'pickup'
require 'redis'

module Brane
  class Redis
    attr_writer :redis

    def add(text)
      return unless text =~ /\A\w/

      text.split(/\b[!?\.]+\s+/).map do |sentence|
        normalized_word = nil

        sentence.split(/\s+/).map do |word|
          normalized_word = normalize_word(word)
          [word_to_id(normalized_word), normalized_word]
        end
      end.select do |sentence|
        sentence.size > 1
      end.each do |sentence|
        redis.sadd 'roots', sentence[0][0]

        sentence.each_cons(2) do |current, after|
          redis.set "words:#{current[0]}", current[1]
          redis.zincrby "words:#{current[0]}:children", 1, after[0]
        end

        redis.zincrby "words:#{sentence[-1][0]}:children", 1, '__term'

        redis.incr 'sentences:count'
        redis.incrby 'sentences:length', sentence.size
      end
    end

    def sentence
      sentence = [random_root_word_id]
      max_sentence_length = (average_sentence_length * (rand + 1)).to_i

      max_sentence_length.times do
        sentence << random_child_word_id(sentence.last) || break
      end

      sentence.compact.map do |id|
        id_to_word id
      end.join(' ').strip
    end

    private

    def average_sentence_length
      length, count = *redis.mget('sentences:length', 'sentences:count').map(&:to_i)
      length / count
    end

    def id_to_word(key)
      if key == '__term'
        return
      end

      word = redis.get("words:#{key}")

      if word == '__url'
        random_url
      else
        word
      end
    end

    def normalize_word(word)
      if word =~ %r{\A\w+://.+}
        redis.sadd 'urls', word
        '__url'
      else
        word.delete('"“”').gsub '’', '\''
      end
    end

    def random_child_word_id(parent_word_id)
      children = redis.zrange("words:#{parent_word_id}:children", 0, -1, with_scores: true)

      unless children.empty?
        Pickup.new(children).pick
      end
    end

    def random_root_word_id
      redis.srandmember 'roots'
    end

    def random_url
      redis.srandmember 'urls'
    end

    def redis
      @redis ||= Redis.new
    end

    def word_to_id(word)
      Digest::MD5.hexdigest word.downcase
    end
  end
end
