# frozen_string_literal: true
require_relative 'lyrics_style'
require_relative 'lyricist_base'
require_relative 'lyricist_ui'
require_relative 'lyricist_buttons'
require_relative 'lyricist_editor'
require_relative 'lyricist_core'

def button(params)
  id_f = params[:id] || identity_generator
  width_f = params[:width] || LyricsStyle.dimensions[:standard_width]
  height_f = params[:height] || LyricsStyle.dimensions[:button_height]
  right_f = params[:right] || 0
  bottom_f = params[:bottom] || 0
  top_f = params[:top] || 0
  left_f = params[:left] || 0
  background_f = params[:background] || LyricsStyle.colors[:primary]
  color_f = params[:color] || LyricsStyle.colors[:secondary]
  label_f = params[:label] || :dummy
  parent_f = params[:parent] || :view
  size_f = params[:size] || LyricsStyle.dimensions[:text_small]

  btn = grab(parent_f).box(
    LyricsStyle.button_style({
                               id: id_f,
                               width: width_f,
                               height: height_f,
                               top: top_f,
                               left: left_f,
                               right: right_f,
                               bottom: bottom_f,
                               color: background_f
                             })
  )

  btn.text(
    LyricsStyle.text_style({
                             data: label_f,
                             component: { size: size_f },
                             top: 5,
                             center: true,
                             color: color_f
                           })
  )


  btn
end

def alter_lyric_event
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
      lyrics.data(line_found)
      alter_lyric_event
    end
  end
end

# Création de l'instance et lancement de l'application
lyr = Lyricist.new
import_drag=grab(:import_module)
import_drag.display(:none)


grab(:toolbox_tool).display(:none)
# exxample below

lyr.new_song({ 0 => "hello", 594 => "world dfjhgjh", 838 => "of", 1295 => "hope" })

### set number of line
# set font size
# play / rec shortcut
# replace mode
# dsiplay / change  lyrics at correct time
# # save lyrics
# # # load lyrics
# play audio
# playlist
# send midi
# receive midi
# pause alternate play / pause add @playing instance_var