# lib/tasks/kafka.rake
namespace :kafka do
    desc "Run Kafka consumer with manual acks"
    task consume: :environment do
      config = Rdkafka::Config.new({
        "bootstrap.servers": "localhost:9092",
        "group.id": "rails-consumer-group",
        "enable.auto.commit": "false",
        "auto.offset.reset": "earliest" 
      })
      
      consumer = config.consumer
      consumer.subscribe("central_events")
  
      puts "Consumer started. Waiting for messages..."
      
      consumer.each do |message|
        puts "Received message: #{message.payload}"
        
        # Process message logic here
        # Process(message.payload)
        
        consumer.commit(message)
        puts "Message committed: #{message.offset}"
      rescue => e
        Rails.logger.error "Error processing Kafka message: #{e.message}"
      end
    end
  end
  