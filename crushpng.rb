#!/usr/bin/env ruby

# Applies pngquant to png file(s)
# Convenience script by Eric Dejonckheere 2022/02/15

require 'fileutils'

$formats = [".png"]
$count = 0

def already(item)
  puts "#{item} already processed, skipping"
end

def badext(item)
  puts "#{item} not a supported file format, skipping"
end

def notfile(item)
  puts "#{item} is not a file, skipping"
end

def notdir(item)
  puts "#{item} is not a directory"
end

def process(item)
  dirname = File.dirname item
  outdir = "#{dirname}/processed"
  FileUtils.mkdir_p outdir 
  puts "optimizing #{item}"
  `pngquant -v #{item} -o '#{outdir}/#{item}'`
  puts "saved in #{outdir}/#{item}"
end

def q(item)
  if item.include? "-fs8"
    already item
  else
    if $formats.include? File.extname(item.downcase)
      process item
      $count += 1
    else
      badext item
    end  
  end
end

def help
  puts "Expects either -f filename(s) or -d directoryname"
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
        notfile item
      end
    end
  elsif ARGV[0] == '--directory' || ARGV[0] == '-D' || ARGV[0] == '-d'
    arg = ARGV[1]
    if File.directory? arg
      Dir.foreach(arg) do |item|
        next if item == '.' or item == '..'
        if File.directory? item
          notfile item
        else
          q item
        end
      end
    else
      notdir arg
      exit
    end
  else
    help
  end
end

if $count > 0
  puts "Done. Quantized #{$count} files."
else
  puts "Ended without processing any file."
end
