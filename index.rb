# frozen_string_literal: true
require_relative 'lyrics_style'
require_relative 'lyricist_base'
require_relative 'lyricist_ui'
require_relative 'lyricist_buttons'
require_relative 'lyricist_editor'
require_relative 'lyricist_core'

def alter_lyric_event(lyrics)
  lyrics = grab(:lyric_viewer)
  counter = grab(:counter)
  current_position = counter.timer[:position]
  lyrics.content[current_position] = lyrics.data
  lyrics.blink(LyricsStyle.colors[:danger])
end

def parse_song_lyrics(song)
  song_lines = song.split("\n")
  song_lines.each_with_index do |line_found, index|
    new_id = "a_lyrics_line_#{index}".to_sym
    puts "new_id: #{new_id}, #{index} =>> #{line_found}"

    line_support = grab(:importer_support).box({
                                        id: new_id,
                                        width: 399,
                                        height: 30,
                                        top: index * 33,
                                        left: 3,
                                        color: LyricsStyle.colors[:danger],
                                        smooth: LyricsStyle.decorations[:standard_smooth]
                                      })

    line_support.text({
                        data: line_found,
                        id: "#{new_id}_text",
                        top: 1,
                        left: 1,
                        position: :absolute,
                        width: 399
                      })

    line_support.touch(true) do
      lyrics = grab(:lyric_viewer)
      counter = grab(:counter)
      lyrics.data(line_found)
      alter_lyric_event(lyrics)
    end
  end
end
# Création de l'instance et lancement de l'application
lyr = Lyricist.new
lyr.new_song({ 0 => "hello", 594 => "world", 838 => "of", 1295 => "hope" })

# open_filer = text({ data: :importimportimportimportimportimportimport, top: 120, left: 120, color: :yellowgreen })
# open_filer.import(true) do |val|
#   parse_song_lyrics(val)
# end
# importer do |val|
#   parse_song_lyrics(val[:content])
# end