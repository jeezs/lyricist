# frozen_string_literal: true

# Étape 1 : Définir une fonction JavaScript globale (à exécuter une seule fois au démarrage)
def hide_all_panels
  grab(:import_module).display(:none) if  grab(:import_module)
  grab(:list_panel).display(:none) if  grab(:list_panel)
  grab(:lyrics_editor_container).delete({ recursive: true }) if  grab(:lyrics_editor_container)
  grab(:loader).delete({ recursive: true }) if  grab(:loader)
end



def save_file_to_db(file_name, content_to_save)
    content_string = content_to_save.is_a?(String) ? content_to_save : content_to_save.to_json
    JS.global.localStorage.setItem(file_name, content_string)
end




# Étape 2 : Fonction Ruby simplifiée qui appelle la fonction JavaScript
def load_file(file_name)
  begin
     JS.global.localStorage.getItem(file_name)
  rescue => e
  end
end
def list_all_files_in_localstorage
  # Obtenir le nombre total d'éléments dans localStorage
  storage_length = JS.global.localStorage.length

  # Initialiser un tableau pour stocker les noms de fichiers
  files = []

  # Itérer sur tous les index et récupérer les clés
  storage_length.times do |i|
    key = JS.global.localStorage.key(i)
    files << key
  end

  # Retourner un hash avec la clé :files
  return { files: files }
end
require_relative 'lyrics_style'
require_relative 'lyricist_base'
require_relative 'lyricist_ui'
require_relative 'lyricist_buttons'
require_relative 'lyricist_editor'
require_relative 'lyricist_core'
require_relative 'list'
box({id: :main_stage, width: '100%', height: '100%', overflow: :hidden, color: LyricsStyle.colors[:container_bg]})

# class Audio_player
class Object



  def audio_length(audio_object)
    audio_object.length
  end

  # def play_audio(audio_object, at)
  #   audio_object.play(at) # do |val|
  # end

  # def pause_audio(audio_object)
  #   audio_object.pause(:pause)
  # end
  #
  # def stop_audio(audio_object)
  #   audio_object.play(:stop)
  # end
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
  edition=params[:edit] || false
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
                             id: "#{id_f}_label",
                             component: { size: size_f },
                             top: 5,
                             center: true,
                             color: color_f,
                             edit:edition
                           })
  )

  btn
end

def alter_lyric_event
  lyrics = grab(:lyric_viewer)
  lyrics.content[@actual_position] = lyrics.data
  lyrics.blink(LyricsStyle.colors[:danger])
end

def parse_song_lyrics(song)
  song_lines = song.split("\n")
  song_lines.each_with_index do |line_found, index|
    new_id = "a_lyrics_line_#{index}"

    line_support = grab(:importer_support).box({
                                                 id: new_id,
                                                 width: 399,
                                                 height: 30,
                                                 top: index * 33,
                                                 left: 3,
                                                 color: LyricsStyle.colors[:container_bg],
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

    line_support.touch(:down) do
      lyrics = grab(:lyric_viewer)
      lyrics.data(line_found)
      alter_lyric_event
      update_song_listing
    end
  end
end
audio({  id: :basic_audio })
# Création de l'instance et lancement de l'application


grab(:toolbox_tool).display(:none)

def init_lyrix(lyrics_content, song_path)

  lyr = Lyricist.new
  # we create an atome to  be able to retreive the lyr
  element({id: :the_lyricist, data: lyr})
  lyr.init_audio(song_path)
  lyr.new_song(lyrics_content)
  import_drag = grab(:import_module)
  import_drag.display(:none)
  lyr.initialize_list_manager

  ############
  #autoload here
  result = list_all_files_in_localstorage
  file = result[:files].last

  file_content = load_file(file)

  current_lyricist = grab(:the_lyricist).data
  list_to_load = { filename: file.to_s, content: file_content.to_s }
  current_lyricist.load_strategy(list_to_load)
  # now closing list panel
  hide_all_panels

end

# init_lyrix({ 0 => "hi", 2594 => "jeezs", 8838 => "from", 231295 => "hope" }, 'medias/audios/Alive.mp3')
init_lyrix({ 0 => "hi", 233 => "jeezs" }, 'medias/audios/Alive.mp3')


##### test below
# class Atome
#   def method_missing(name, *args, &block)
#     puts " que faire avec #{name}, #{args}, #{block}"
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
#   puts  a.duration
# end




# ########### example IDB
#
# b = box({ left: 0, text: :save })
#
# b.touch(true) do
#   b.idb_save('eDen', :toto, "hello") do |file_get|
#     puts "file_saved: #{file_get}"
#   end
# end
#
# c = box({ left: 50, text: :load })
#
# c.touch(true) do
#   A.idb_load('eDen', :toto) do |file_get|
#     puts "file_get: #{file_get}"
#   end
# end
#
# d = box({ left: 100, text: :list })
#
# d.touch(true) do
#   A.idb_list(:eDen) do |file_get|
#     puts "file_list: #{file_get}"
#   end
# end
#
# e = box({ left: 150, text: :remove })
#
# e.touch(true) do
#   A.idb_remove('eDen', :toto) do |file_get|
#     puts "file_remove: #{file_get}"
#   end
# end
#
# f = box({ left: 200, text: :reset })
#
# f.touch(true) do
#   A.idb_reset(:eDen)do |file_get|
#     puts "file_reset: #{file_get}"
#   end
# end

