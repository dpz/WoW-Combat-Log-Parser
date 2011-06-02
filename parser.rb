# Copyright Dave Ball 2011

if(!$".include? "date.rb")
    require "Date"
end

class Parser
    def initialize time_size = 3, time_unit = "M", freq = 10000
        @freq = freq
        @data_unit_size = 1024*1024
        @data_unit_string = "MB"
        @time_unit = time_unit
        @threshold = DateTime.strptime("#{time_size}", "%#{@time_unit}") - DateTime.strptime("0", "%#{@time_unit}")
    end

    def parse(inputName)
        puts "Parsing #{inputName}"

        input = File.new(inputName)

        i = 0
        parsed = 0
        size = (File.size input)/@data_unit_size
        prevtimestring = nil
        prevtime = nil
        curtime = nil
        output = nil
        last = nil

        input.each do |line|
            line =~ /^(\d{1,2}\/\d{1,2} \d{1,2}:\d{2}:\d{2})/

            (curtime = DateTime.strptime($1, "%m/%d %H:%M:%S")) if !$1.eql?(prevtimestring)

            if output.nil?
                output = newFile(curtime)
            elsif !prevtime.nil? && ((curtime - prevtime) >= @threshold) then
                output.close

                output = newFile(curtime)
            end

            output.puts(line)

            prevtime = curtime
            prevtimestring = $1
            parsed += line.length

            if(((i = i.next) % @freq) == 0)
                print (last = "\rLine: #{i}, #{parsed/@data_unit_size} #{@data_unit_string} of #{size} #{@data_unit_string} parsed. (#{((parsed/@data_unit_size)*100)/size}%)\r")
            end

        end

        puts "Done!#{' '*(last.length-5)}"
    end

    def newFile(curtime)
        File.new("#{curtime.strftime("%Y-%m-%d %H-%M-%S")}.txt", "w")
    end
end

if __FILE__ == $0
    if ARGV.empty?
        ARGV << "WoWCombatLog.txt"
    end

    p = case
        when ARGV[1].nil? 
            Parser.new
        when ARGV[2].nil? 
            Parser.new ARGV[1]
        when ARGV[3].nil? 
            Parser.new ARGV[1], ARGV[2]
        else
            Parser.new ARGV[1], ARGV[2], ARGV[3]
    end

    begin
        p.parse(ARGV[0])
    rescue
        puts "File could not be found or read."
    end
end