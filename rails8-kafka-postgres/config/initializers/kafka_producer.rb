# config/initializers/kafka_producer.rb
KAFKA_PRODUCER = Rdkafka::Config.new({
  "bootstrap.servers": "localhost:9092",
  "client.id": "rails-8-kafka",
  "acks": "all"  
}).producer

# To ensure the producer flushes pending messages on shutdown
# at_exit { KAFKA_PRODUCER.close }
