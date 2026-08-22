#!/usr/bin/env ruby
# Generates distinct temporary PCM signals for local app development.

require "fileutils"

sample_rate = 44_100
output = File.expand_path("../../Main/Resources/Audio", __dir__)
FileUtils.mkdir_p(output)

def clamp(sample)
  [[sample.round, -32_768].max, 32_767].min
end

def envelope(progress, attack:, decay:)
  if progress < attack
    progress / attack
  else
    Math.exp(-(progress - attack) * decay)
  end
end

def harmonic_tone(sample_rate, frequency:, duration:, amplitude:, harmonics:, attack: 0.005, decay: 5.0)
  sample_count = (sample_rate * duration).to_i
  Array.new(sample_count) do |index|
    progress = index.fdiv(sample_count)
    env = envelope(progress, attack: attack, decay: decay)
    value = harmonics.sum do |multiple, weight|
      Math.sin(2 * Math::PI * frequency * multiple * index / sample_rate) * weight
    end
    clamp(amplitude * env * value)
  end
end

def noise_click(sample_rate, duration:, amplitude:, seed:, decay: 18.0)
  random = Random.new(seed)
  sample_count = (sample_rate * duration).to_i
  Array.new(sample_count) do |index|
    progress = index.fdiv(sample_count)
    env = Math.exp(-progress * decay)
    color = Math.sin(2 * Math::PI * 1_700 * index / sample_rate) * 0.35
    value = (random.rand * 2.0 - 1.0) * 0.65 + color
    clamp(amplitude * env * value)
  end
end

def silence(sample_rate, duration)
  Array.new((sample_rate * duration).to_i, 0)
end

def mix(*tracks)
  max_length = tracks.map(&:length).max
  Array.new(max_length) do |index|
    clamp(tracks.sum { |track| track[index] || 0 })
  end
end

single_gong = harmonic_tone(
  sample_rate,
  frequency: 520,
  duration: 0.95,
  amplitude: 11_000,
  harmonics: [[1.0, 0.85], [2.01, 0.30], [2.97, 0.18], [4.10, 0.10]],
  attack: 0.003,
  decay: 4.3
)

triple_gong_hit = harmonic_tone(
  sample_rate,
  frequency: 700,
  duration: 0.24,
  amplitude: 10_000,
  harmonics: [[1.0, 0.8], [2.0, 0.22], [3.01, 0.14]],
  attack: 0.002,
  decay: 8.0
)
triple_gong = triple_gong_hit + silence(sample_rate, 0.06) + triple_gong_hit + silence(sample_rate, 0.06) + triple_gong_hit

bright_bell = mix(
  harmonic_tone(
    sample_rate,
    frequency: 1_020,
    duration: 0.70,
    amplitude: 8_500,
    harmonics: [[1.0, 0.75], [2.0, 0.28], [3.2, 0.16], [5.4, 0.07]],
    attack: 0.002,
    decay: 5.8
  ),
  harmonic_tone(
    sample_rate,
    frequency: 1_530,
    duration: 0.45,
    amplitude: 2_400,
    harmonics: [[1.0, 1.0], [2.4, 0.25]],
    attack: 0.002,
    decay: 8.0
  )
)

signals = {
  "placeholder_round.wav" => single_gong,
  "placeholder_complete.wav" => triple_gong,
  "placeholder_bright.wav" => bright_bell
}

signals.each do |name, samples|
  pcm = samples.pack("s<*")
  header = ["RIFF", 36 + pcm.bytesize, "WAVE", "fmt ", 16, 1, 1, sample_rate,
            sample_rate * 2, 2, 16, "data", pcm.bytesize].pack("A4VA4A4VvvVVvvA4V")
  File.binwrite(File.join(output, name), header + pcm)
end
