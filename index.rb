# frozen_string_literal: true
require_relative 'lyrics_style'
require_relative 'lyricist_base'
require_relative 'lyricist_ui'
require_relative 'lyricist_buttons'
require_relative 'lyricist_editor'
require_relative 'lyricist_core'

# class Audio_player
class Object

  def audio_length(audio_object)
    audio_object.length
  end

  def play_audio(audio_object, at)
    audio_object.play(at) # do |val|
  end

  def pause_audio(audio_object)
    audio_object.pause(:pause)
  end

  def stop_audio(audio_object)
    audio_object.play(:stop)
  end
end

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

# import_drag=grab(:import_module)
# import_drag.display(:none)

grab(:toolbox_tool).display(:none)

def load_song(lyrics_path, song_path)
  # 'medias/audios/Ices_From_Hells.m4a'
  lyr = Lyricist.new
  lyr.init_audio('medias/audios/Ices_From_Hells.m4a')
  lyr.new_song({ 0 => "hello", 2594 => "world dfjhgjh", 8838 => "of", 231295 => "hope" })
  import_drag = grab(:import_module)
  import_drag.display(:none)
end

load_song('', '')

# lyr.player
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

# player(:jj, :ll)

##### test below
# class Atome
#   def method_missing(name, *args, &block)
#     alert " que faire avec #{name}, #{args}, #{block}"
#   end
# end
# a=audio({path:'medias/audios/Ices_From_Hells.m4a' })
# cc=box({top: 130})
# cc.touch(:down) do
#   a.volume(0.5)
# end
#
# ccc=box({top: 170})
# ccc.touch(:down) do
#   alert  a.duration
# end
