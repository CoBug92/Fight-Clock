#!/usr/bin/env ruby
# Generates temporary PCM signals. Replace these files with licensed production audio before release.

require "fileutils"

sample_rate = 44_100
output = File.expand_path("../../Resources/Sounds", __dir__)
FileUtils.mkdir_p(output)

signals = {
  "placeholder_round.wav" => [[880, 0.18], [0, 0.06], [880, 0.18]],
  "placeholder_rest.wav" => [[440, 0.42]],
  "placeholder_complete.wav" => [[660, 0.15], [0, 0.05], [880, 0.15], [0, 0.05], [1100, 0.28]]
}

signals.each do |name, segments|
  samples = segments.flat_map do |frequency, duration|
    count = (sample_rate * duration).to_i
    Array.new(count) do |index|
      frequency.zero? ? 0 : (Math.sin(2 * Math::PI * frequency * index / sample_rate) * 12_000).to_i
    end
  end

  pcm = samples.pack("s<*")
  header = ["RIFF", 36 + pcm.bytesize, "WAVE", "fmt ", 16, 1, 1, sample_rate,
            sample_rate * 2, 2, 16, "data", pcm.bytesize].pack("A4VA4A4VvvVVvvA4V")
  File.binwrite(File.join(output, name), header + pcm)
end

