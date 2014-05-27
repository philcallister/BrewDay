module BrewTimer

  class Timer

    attr_reader :timer_running, :seconds

    def initialize
      @label = nil
      @timer = nil
      @seconds = 0
      @timer_running = false
      @procs = []
    end

    def add(id, &block)
      if @procs.detect { |p| p[:id] == id }
        @procs.map! { |p| p[:id] == id ? { :id => id, :proc => block } : p }
      else
        @procs << { :id => id, :proc => block } if block.is_a? Proc
      end
    end

    def toggle
      @timer_running = !@timer_running
      if @timer_running
        @seconds = 0
        start
      else
        cancel
      end
    end


    ############################################################################
    # Delegate interface

    def elapsed(seconds)
      puts "!!!!! elapsed() : #{@seconds} + #{seconds}"
      @seconds += seconds
    end


    private

      def start
        cancel
        @timer = EM.add_periodic_timer 1.0 do
          tic
          @procs.each do |p|
            p[:proc].call(@seconds)
          end
        end
        App.delegate.timer = self
      end

      def cancel
        EM.cancel_timer(@timer) if @timer
        @timer = nil
        App.delegate.timer = nil
      end

      def tic
        @seconds = @seconds + 1
      end

  end

end
