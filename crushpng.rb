#!/usr/bin/env ruby

# Applies pngquant to png file(s)
# Convenience script by Eric Dejonckheere 2022/02/15

require 'fileutils'

$formats = [".png"]
$count = 0

def q(item)
  if item.include? "-fs8"
    puts "#{item} already processed, skipping"
  else
    if $formats.include? File.extname(item.downcase)
      dirname = File.dirname item
      outdir = "#{dirname}/processed"
      FileUtils.mkdir_p outdir 
      puts "optimizing #{item}"
      `pngquant -v #{item} -o '#{outdir}/#{item}'`
      puts "saved in #{outdir}/#{item}"
      $count += 1
    else
      puts "#{item} not a supported file format, skipping"
    end  
  end
end

def help
  puts "Expects either -f filename(s) or -d directoryname\n"
  exit
end

if ARGV.empty?
  help
else
  if ARGV[0] == '--files' || ARGV[0] == '-F' || ARGV[0] == '-f'
    ARGV.shift
    for item in ARGV do
      if File.file? item
        q item
      else
        puts "#{item} is not a file, skiping\n"
      end
    end
  elsif ARGV[0] == '--directory' || ARGV[0] == '-D' || ARGV[0] == '-d'
    arg = ARGV[1]
    if File.directory? arg
      Dir.foreach(arg) do |item|
        next if item == '.' or item == '..'
        if File.directory? item
          puts "#{item} is not a file, skiping\n"
        else
          q item
        end
      end
    else
      puts "Not a directory\n"
      exit
    end
  else
    help
  end
end

if $count > 0
  puts "Done. Quantized #{$count} files.\n"
else
  puts "Ended without processing any file.\n"
end
