module Sidekiq
  module History
    class RedisStatistic
      def initialize(start_date, end_date)
        @start_date = start_date
        @end_date = end_date
      end

      def for_worker(worker)
        hash.map{ |h| h.values.first[worker] || {} }
      end

      def worker_names
        @worker_names ||= hash.flat_map{ |hash| hash.values.first.keys }.uniq
      end

      def hash
        @redis_hash = Sidekiq.redis do |conn|
          (@end_date..@start_date).map do |date|
            {
              date.to_s => parse(conn.get("sidekiq:history:#{date}"))
            }
          end
        end
      end

    private

      def parse(json)
        hash = Sidekiq.load_json(json || '{}')
        hash.each do |worker, attributes|
          hash[worker] = attributes.symbolize_keys
        end
      end
    end
  end
end
