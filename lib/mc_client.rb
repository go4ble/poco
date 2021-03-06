require 'serialport'
require 'thread'

# TODO timeout exception

class McClient
  MC_PORT = ENV['MC_PORT'] || raise('MC_PORT undefined')
  BAUD_RATE = 9600
  DATA_BITS = 8
  STOP_BITS = 1
  PARITY = SerialPort::NONE

  @@semaphore = Mutex.new

  def self.method_missing(method, *arguments, &block)
    send_command(method.to_s)
  end

  def self.send_command(command)
    response = nil
    @@semaphore.synchronize do
      @@sp ||= SerialPort.new(MC_PORT, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY)
      begin
        @@sp.read_timeout = 5000
        @@sp.puts command
        response = @@sp.gets.chomp rescue nil
      end
    end
    response
  end
end
