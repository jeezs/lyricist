# frozen_string_literal: true

class Lyricist < Atome

  def set_list(filename, content)
    # alert filename
    # alert content.class
    # @list_title = filename
    list_content = eval(content)
    @list = list_content
  end

  def load_strategy(val)
    filename = val[:filename]
    content = val[:content]

    current_lyricist = grab(:the_lyricist).data
    # puts "filename: #{filename}"
    # puts "extname: #{File.extname(filename).downcase}"

    # begin
      case File.extname(filename).downcase
      when ".mp3", ".wav", ".ogg", ".aac", ".flac", ".m4a"
        # puts "===> audio case"
        audio_path="medias/audios/#{filename}"
        current_lyricist.init_audio(audio_path)
        return # Add explicit return
      when ".txt"
      #   alert :yes
      #   puts "===> text case"
        grab(:importer_support).clear(true)
        parse_song_lyrics(val[:content])
      grab(:import_module).display(:block)
        # grab(:lyric_viewer).content(lyrics)
        # current_lyricist.full_refresh_viewer(0)
        return # Add explicit return
      when ".lrx"
        puts "===> lrx case"
        # begin
          file_to_load = eval(content)
          lyrics = eval(file_to_load['lyrics'])
          audio_path = file_to_load['song']
          title = file_to_load['title']
          current_lyricist.clear_all
          @title = title
          grab('title_label').data(title)
          current_lyricist.init_audio(audio_path)
          grab(:lyric_viewer).content(lyrics)
          @lyrics = grab(:lyric_viewer).content(lyrics)
          current_lyricist.full_refresh_viewer(0)
        # rescue => e
        #   puts "Error in LRX processing: #{e.message}"
        # end
        return # Add explicit return
      when ".prx"

        # puts "===> lrs case"
        current_lyrix = grab(:the_lyricist).data
        current_lyrix.set_list(filename, content)
        return # Add explicit return
      else
        puts "===> else case"
        # puts "Extension inconnue"
      end
    # rescue => e
    #   puts "Error in case statement: #{e.message}"
    # end
  end

  def wait_for_duration(audio_object, callback)
    # Vérifier si duration existe et convertir en Float Ruby
    duration_value = audio_object.duration.to_f rescue nil

    if duration_value && duration_value > 0
      # Duration est définie, exécuter le callback
      callback.call(duration_value)
    else
      # Planifier une nouvelle vérification après un court délai
      JS.global.setTimeout(-> { wait_for_duration(audio_object, callback) }, 100)
    end
  end

  def seconds_to_minutes(seconds)
    minutes = seconds / 60
    remaining_seconds = seconds % 60
    "#{minutes}:#{remaining_seconds.to_s.rjust(2, '0')}"
  end

  def init_audio(audio_path)
    @audio_object = grab(:basic_audio)
    @audio_path = audio_path
    @audio_object.path(audio_path)
    wait_for_duration(@audio_object, ->(duration) {
      @default_length = duration * 1000
      @length = duration * 1000
    })
  end

  def build_control_buttons

    play = button({
                    label: :play,
                    id: :play,
                    top: LyricsStyle.dimensions[:margin],
                    left: LyricsStyle.dimensions[:margin],
                    parent: :tool_bar
                  })

    play.touch(true) do

      if @playing
        grab(:counter).timer({ pause: true })
        @playing = false
        stop_audio(@audio_object)
      else

        counter = grab(:counter)
        play_audio(@audio_object, @actual_position / 1000)
        prev_length = @length
        counter.timer({ end: Float::INFINITY }) do |value|
          lyrics = grab(:lyric_viewer)
          value = value.to_i
          update_lyrics(value, lyrics, counter)
          if @record && value >= @length
            @length = value
          else
            if value >= @length
              counter.timer({ stop: true })
            end
          end
          if value < prev_length
            grab(:timeline_slider).value(value)
          end

        end
        @playing = true
      end
    end

    edit_lyrics = button({
                           label: "Edit",
                           id: :edit_lyrics_button,
                           left: :auto,
                           right: LyricsStyle.dimensions[:margin],
                           top: LyricsStyle.dimensions[:margin],
                           size: LyricsStyle.dimensions[:text_medium],
                           parent: :tool_bar
                         })

    edit_lyrics.touch(true) do
      if @editor_open
        # Fermer l'éditeur s'il est déjà ouvert
        grab(:lyrics_editor_container).delete({ recursive: true }) if grab(:lyrics_editor_container)
        @editor_open = false
      else
        # Ouvrir l'éditeur
        @editor_open = true
        show_lyrics_editor(33, 33)
      end
    end

    # Bouton Erase
    erase = button({
                     id: :erase,
                     label: :clear,
                     color: LyricsStyle.colors[:accent],
                     top: LyricsStyle.dimensions[:margin],
                     left: LyricsStyle.positions[:fourth_column],
                     parent: :tool_bar
                   })

    erase.touch(true) do
      clear_all
    end

    ###
    view_importer = button({
                             id: :import_viewer,
                             label: :lyrics,
                             top: LyricsStyle.dimensions[:margin],
                             left: :auto,
                             right: LyricsStyle.positions[:second_column],
                             parent: :tool_bar
                           })

    view_importer.touch(true) do
      import_drag = grab(:import_module)
      if import_drag.display == :none
        import_drag.display(:block)
      else
        import_drag.display(:none)
      end
    end

    ###########

    record = button({
                      label: 'modify',
                      id: :record,
                      top: LyricsStyle.dimensions[:margin],
                      left: LyricsStyle.positions[:third_column],
                      parent: :tool_bar
                    })

    record.touch(true) do
      prev_postion = @actual_position
      lyric_viewer = grab(:lyric_viewer)
      if @record == true
        @record = false
        lyric_viewer.edit(false)
        record.color(LyricsStyle.colors[:primary])
        @number_of_lines = @original_number_of_lines
      else
        @record = true
        record.color(LyricsStyle.colors[:danger])
        # record.alpha(1)
        lyric_viewer.edit(true)
        @number_of_lines = 1

        counter = grab(:counter)
        lyrics = grab(:lyric_viewer)
        update_lyrics(0, lyrics, counter)
      end
      full_refresh_viewer(prev_postion)
    end

    #########

    clear = button({
                     label: 'clear',
                     id: :clear,
                     top: LyricsStyle.dimensions[:margin],
                     color: LyricsStyle.colors[:accent],

                     # color: :yellow,
                     # background: :red,
                     left: LyricsStyle.positions[:second_column],
                     parent: :import_module
                   })

    clear.touch(true) do
      grab(:importer_support).clear(true)
    end
    ###########

    # Bouton Stop
    stop = button({
                    label: :stop,
                    id: :stop,
                    top: LyricsStyle.dimensions[:margin],
                    color: LyricsStyle.colors[:secondary],
                    left: LyricsStyle.positions[:second_column],
                    parent: :tool_bar
                  })

    stop.touch(true) do
      stop_audio(@audio_object)
      counter = grab(:counter)
      counter.timer({ stop: true })
      lyrics = grab(:lyric_viewer)
      update_lyrics(0, lyrics, counter)
      grab(:timeline_slider).delete({ force: true })
      build_timeline_slider
      @playing = false
    end

    prev_word = button({
                         label: :<,
                         width: 25,
                         id: :previous,
                         top: LyricsStyle.dimensions[:margin],
                         left: LyricsStyle.positions[:prev],
                         parent: :bottom_bar
                       })

    next_word = button({
                         label: :>,
                         width: 25,
                         top: LyricsStyle.dimensions[:margin],
                         id: :next,
                         left: LyricsStyle.positions[:next],
                         parent: :bottom_bar
                       })

    prev_word.touch(true) do
      lyrics = grab(:lyric_viewer)
      counter = grab(:counter)
      current_position = counter.timer[:position]

      # Trouver la clé qui précède la position actuelle
      sorted_keys = lyrics.content.keys.sort
      prev_index = sorted_keys.rindex { |key| key < current_position }

      if prev_index
        prev_position = sorted_keys[prev_index]
        update_lyrics(prev_position, lyrics, counter)
        grab(:timeline_slider).value(prev_position)
      else
        # Si aucune position précédente n'est trouvée, aller au début (position 0)
        update_lyrics(0, lyrics, counter)
        grab(:timeline_slider).value(0)
      end
    end

    next_word.touch(true) do
      lyrics = grab(:lyric_viewer)
      counter = grab(:counter)
      current_position = counter.timer[:position]

      # Trouver la clé qui suit la position actuelle
      sorted_keys = lyrics.content.keys.sort
      next_index = sorted_keys.find_index { |key| key > current_position }

      if next_index
        next_position = sorted_keys[next_index]
        update_lyrics(next_position, lyrics, counter)
        grab(:timeline_slider).value(next_position)
      else
        # Si aucune position suivante n'est trouvée, aller à la fin
        last_position = sorted_keys.last
        update_lyrics(last_position, lyrics, counter)
        grab(:timeline_slider).value(last_position)
      end
    end

    import_lyrics = button({
                             label: :import,
                             id: :import_lyrics,
                             # color: LyricsStyle.colors[:accent],
                             text_color: :black,
                             top: LyricsStyle.dimensions[:margin],
                             left: 3,
                             parent: :import_module
                           })

    import_lyrics.import(true) do |val|
      grab(:importer_support).clear(true)
      parse_song_lyrics(val[:content])
    end

    #######
    close_import = button({
                            label: :close,
                            id: :close_import,
                            top: LyricsStyle.dimensions[:margin],
                            left: :auto,
                            right: 3,
                            parent: :import_module
                          })
    import_drag = grab(:import_module)
    close_import.touch(true) do |val|
      if import_drag.display == :none
        import_drag.display(:block)
      else
        import_drag.display(:none)
      end
    end

    #######

    save_song = button({
                         label: :save,
                         id: :save,
                         top: LyricsStyle.dimensions[:margin],
                         left: 525,
                         parent: :bottom_bar
                       })
    save_song.touch(true) do
      lyrics = grab(:lyric_viewer).content.to_s
      content_to_save = { lyrics: lyrics, song: @audio_path, title: @title }

      save_file("#{@title}.lrx", content_to_save)
    end

    #########


    load_song = button({
                         label: :load,
                         id: :load,
                         top: LyricsStyle.dimensions[:margin],
                         left: 465,
                         parent: :bottom_bar
                       })
    load_song.import(true) do |val|
      current_lyricist = grab(:the_lyricist).data
      current_lyricist.load_strategy(val)

    end
    # load_song.import(true) do |val|
    #
    #   filename = val[:filename]
    #   content = val[:content]
    #
    #   current_lyricist = grab(:the_lyricist).data
    #   # we clear the current lyrics
    #   # alert File.extname(filename).downcase
    #   puts "filename: #{filename.to_s}"
    #   puts "extname: #{File.extname(filename.to_s).downcase}"
    #   case File.extname(filename).downcase
    #   when ".mp3", ".wav", ".ogg", ".aac", ".flac", ".m4a"
    #     puts "===> audio case"
    #     # current_lyricist.init_audio(audio_path)
    #   when ".txt"
    #     puts "===> text case"
    #     # grab(:lyric_viewer).content(lyrics)
    #     # current_lyricist.full_refresh_viewer(0)
    #   when ".lrx"
    #     puts "===> lrx case"
    #     file_to_load = eval(content)
    #     lyrics = eval(file_to_load['lyrics'])
    #     audio_path = file_to_load['song']
    #     title = file_to_load['title']
    #     current_lyricist.clear_all
    #     @title = title
    #     grab('title_label').data(title)
    #     current_lyricist.init_audio(audio_path)
    #     grab(:lyric_viewer).content(lyrics)
    #     @lyrics = grab(:lyric_viewer).content(lyrics)
    #     current_lyricist.full_refresh_viewer(0)
    #   when ".lrs"
    #     puts "===> lrs case"
    #     current_lyrix = grab(:the_lyricist).data
    #     current_lyrix.set_list(filename, content)
    #   else
    #     puts "===> else case"
    #     # puts "Extension inconnue"
    #   end
    # end

    titesong = button({
                        label: @title,
                        id: :title,
                        top: LyricsStyle.dimensions[:margin],
                        left: 250,
                        width: 120,
                        edit: true,
                        parent: :tool_bar
                      })
    titesong.keyboard(:down) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13' # Touche Entrée
        titesong.blink(:orange)
        event.preventDefault
        title = grab('title_label')
        @title = title.data
      end
    end
  end
end