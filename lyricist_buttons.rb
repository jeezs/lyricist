# frozen_string_literal: true

class Lyricist < Atome

  def set_list(content)
    list_content = eval(content)
    @list = list_content
  end

  def set_imported_lyrics(lyr)
    @imported_lyrics = lyr
  end

  def loading_countdown(next_song, allow_countdown)

    if allow_countdown
      countdown = grab("lyrics_support").box({ id: :load_warning, width: 120, height: 120 })
      countdown.smooth(120)
      countdown.color(LyricsStyle.colors[:third])
      countdown.shadow(LyricsStyle.decorations[:container_shadow])
      countdown.center(true)
      @allow_loading = true
      countdown.touch(true) do
        @allow_loading = false
      end
      countdown_size = 69
      countdown_label = countdown.text({ data: 3, size: countdown_size })
      countdown_label.color(LyricsStyle.colors[:first_line_color])
      countdown_label.center(true)
      countdown_label.touch(true) do
        @allow_loading = false
      end
      wait 1 do
        countdown_label.data(2)
        countdown_label.size(countdown_size - (countdown_size / 3))
        countdown_label.center(true)
        wait 1 do
          countdown_label.data(1)
          countdown_label.size(countdown_size - (countdown_size / 3))
          countdown_label.center(true)
        end
      end
      wait 3 do
        if @allow_loading
          load_song_from_list(next_song)
          play_lyrics
          @allow_next = true
          @allow_loading = true
        else
          play_next_song({ current: true, immediate: true })
        end
        countdown.delete({ recursive: true })
      end
    else
      load_song_from_list(next_song)

    end

  end

  def play_next_song(params = {})
    song_to_load = if params[:prev]
                     -1
                   else
                     1
                   end
    song_to_load = 0 if params[:current]

    loading_countdown = if params[:immediate]
                          false

                        else
                          true
                        end
    @allow_next = false
    grab(:main_line).data = ''
    next_song = (find_key_by_title(@list, @title).to_i + song_to_load).to_s
    if next_song.to_i < @list.length + 1
      loading_countdown(next_song, loading_countdown)
    else
      wait 1 do
        current_song = (next_song.to_i - 1).to_s
        load_song_from_list(current_song)
        @allow_next = true
        puts 'ending of the list'
      end
    end
  end

  def stop_lyrics
    stop_audio(@audio_object)
    lyrics = grab(:main_line)
    update_lyrics(0, lyrics)
    grab(:timeline_slider).delete({ force: true })
    build_timeline_slider
    @playing = false
    @actual_position = 0
    grab(:counter).data(0)
    play_next_song if grab(:main_line).data == '-end-' && @allow_next
  end

  def play_audio(audio_object, actual_position)
    current_lyricist = grab(:the_lyricist).data
    @length = current_lyricist.instance_variable_get('@length')
    @record = current_lyricist.instance_variable_get('@record')
    current_lyricist.instance_variable_get('@actual_position')
    slider = grab(:timeline_slider)
    audio_object.play(actual_position) do |params|
      value = params[:time].round(1)
      slider.value(value)
    end

    @playing = true
  end

  def pause_audio(audio_object)
    audio_object.pause(:pause)
  end

  def stop_audio(audio_object)
    audio_object.play(:stop)
  end

  def play_lyrics
    if @playing
      grab(:counter).timer({ pause: true })
      @playing = false
      stop_audio(@audio_object)
    else
      play_audio(@audio_object, @actual_position)
    end
  end

  def load_strategy(val)
    filename = val[:filename]
    content = val[:content]
    current_lyricist = grab(:the_lyricist).data

    case File.extname(filename).downcase
    when ".mp3", ".wav", ".ogg", ".aac", ".flac", ".m4a"
      audio_path = "medias/audios/#{filename}"
      current_lyricist.init_audio(audio_path)
      name_without_extension = File.basename(filename, File.extname(filename))
      @title = name_without_extension
      grab(:title_label).data(name_without_extension)
      return
    when ".txt"
      grab(:importer_support).clear(true)
      parse_song_lyrics(val[:content])
      grab(:import_module).display(:block)
      @imported_lyrics = val[:content]
    when ".lrx"
      file_to_load = eval(content)
      lyrics = eval(file_to_load['lyrics'])
      audio_path = file_to_load['song']
      title = file_to_load['title']
      current_lyricist.clear_all
      @title = title
      grab('title_label').data(title)
      current_lyricist.init_audio(audio_path)
      grab(:main_line).content(lyrics)
      @lyrics = grab(:main_line).content(lyrics)
      current_lyricist.full_refresh_viewer(0)
      raw = file_to_load['raw']
      grab(:importer_support).clear(true)
      parse_song_lyrics(raw)
      @imported_lyrics = raw
      return
    when ".prx"
      name_without_extension = File.basename(filename, File.extname(filename))
      @list_title = name_without_extension
      grab(:list_title).data = name_without_extension

      current_lyrix = grab(:the_lyricist).data
      current_lyrix.set_list(content)
      refresh_song_list
      grab(:list_panel).display(:block)
      load_song_from_list("1")
      return
    end
    update_song_listing
  end

  def wait_for_duration(audio_object, callback)
    duration_value = audio_object.duration.to_f rescue nil

    if duration_value && duration_value > 0
      callback.call(duration_value)
    else
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
      @default_length = duration
      @length = duration
      full_refresh_viewer(0)
    })
  end

  def build_control_buttons

    play = button({
                    label: :play,
                    id: :play,
                    top: LyricsStyle.dimensions[:margin],
                    left: 25,
                    parent: :tool_bar
                  })

    play.touch(true) do
      play_lyrics
    end

    edit_lyrics = button({
                           label: :Edit,
                           id: :edit_lyrics_button,
                           left: 635,
                           right: LyricsStyle.dimensions[:margin],
                           top: LyricsStyle.dimensions[:margin],
                           size: LyricsStyle.dimensions[:text_medium],
                           parent: :tool_bar
                         })

    edit_lyrics.touch(true) do
      if @editor_open
        grab(:lyrics_editor_container).delete({ recursive: true }) if grab(:lyrics_editor_container)
        @editor_open = false
      else
        @editor_open = true
        grab(:import_module).display(:none)
        show_lyrics_editor(33, 33)
        grab(:list_panel).display(:none)
      end
      update_song_listing
    end

    erase = button({
                     id: :erase,
                     label: :clear,
                     color: LyricsStyle.colors[:accent],
                     top: LyricsStyle.dimensions[:margin],
                     left: LyricsStyle.positions[:fourth_column]+25,
                     parent: :tool_bar
                   })

    erase.touch(true) do

      clear_all
      update_song_listing
    end

    view_importer = button({
                             id: :import_viewer,
                             label: :lyrics,
                             top: LyricsStyle.dimensions[:margin],
                             left: 570,
                             right: LyricsStyle.positions[:second_column],
                             parent: :tool_bar
                           })

    view_importer.touch(true) do
      import_drag = grab(:import_module)
      if import_drag.display == :none
        import_drag.display(:block)
        grab(:lyrics_editor_container).delete({ recursive: true }) if grab(:lyrics_editor_container)
        grab(:list_panel).display(:none)
      else
        import_drag.display(:none)
      end
      update_song_listing
    end

    record = button({
                      label: 'modify',
                      id: :record,
                      top: LyricsStyle.dimensions[:margin],
                      left: LyricsStyle.positions[:third_column]+25,
                      parent: :tool_bar
                    })

    record.touch(true) do
      prev_postion = @actual_position
      lyric_viewer = grab(:main_line)
      if @record == true
        @record = false
        lyric_viewer.edit(false)
        record.color(LyricsStyle.colors[:primary])
        @number_of_lines = @original_number_of_lines
      else
        @record = true
        record.color(LyricsStyle.colors[:danger])
        lyric_viewer.edit(true)
        @number_of_lines = 1

        counter = grab(:counter)
        lyrics = grab(:main_line)
        update_lyrics(0, lyrics, counter)
      end
      full_refresh_viewer(prev_postion)
    end

    clear = button({
                     label: 'clear',
                     id: :clear,
                     top: LyricsStyle.dimensions[:margin],
                     color: LyricsStyle.colors[:accent],
                     left: LyricsStyle.positions[:second_column]+25,
                     parent: :import_module
                   })

    clear.touch(true) do
      grab(:importer_support).clear(true)
    end

    stop = button({
                    label: :stop,
                    id: :stop,
                    top: LyricsStyle.dimensions[:margin],
                    color: LyricsStyle.colors[:secondary],
                    left: LyricsStyle.positions[:second_column]+25,
                    parent: :tool_bar
                  })

    stop.touch(true) do
      stop_lyrics
    end

    prev_word = button({
                         label: :<,
                         width: 25,
                         id: :previous,
                         top: 6,
                         left: LyricsStyle.positions[:prev],
                         parent: :bottom_bar
                       })

    next_word = button({
                         label: :>,
                         width: 25,
                         top:6,
                         id: :next,
                         left: LyricsStyle.positions[:next],
                         parent: :bottom_bar
                       })

    prev_word.touch(:down) do
      stop_audio(@audio_object)
      lyrics = grab(:main_line)
      sorted_keys = lyrics.content.keys.sort
      prev_index = sorted_keys.rindex { |key| key < @actual_position }

      if prev_index
        prev_position = sorted_keys[prev_index]
        @actual_position = prev_position
        update_lyrics(prev_position, lyrics)
        grab(:timeline_slider).value(prev_position)
      else
        update_lyrics(0, lyrics)
        grab(:timeline_slider).value(0)
      end
    end
    prev_word.touch(:up) do
      wait 0.5 do
        play_audio(@audio_object, @actual_position) if @playing
      end
    end

    next_word.touch(:down) do
      stop_audio(@audio_object)
      lyrics = grab(:main_line)
      sorted_keys = lyrics.content.keys.sort
      next_index = sorted_keys.find_index { |key| key > @actual_position }
      if next_index

        next_position = sorted_keys[next_index]
        @actual_position = next_position
        update_lyrics(next_position, lyrics)
        grab(:timeline_slider).value(next_position)
      else
        last_position = sorted_keys.last
        update_lyrics(last_position, lyrics)
        grab(:timeline_slider).value(last_position)
      end
    end
    next_word.touch(:up) do
      play_audio(@audio_object, @actual_position) if @playing
    end

    import_lyrics = button({
                             label: :import,
                             id: :import_lyrics,
                             text_color: :black,
                             top: LyricsStyle.dimensions[:margin],
                             left: 3,
                             parent: :import_module
                           })

    import_lyrics.import(true) do |val|

      grab(:importer_support).clear(true)
      parse_song_lyrics(val[:content])
      current_lyrix = grab(:the_lyricist).data
      current_lyrix.set_imported_lyrics(val[:content])

    end

    save_edited_text = button({
                                label: :save,
                                id: :save_edit,
                                top: LyricsStyle.dimensions[:margin],
                                left: :auto,
                                right: 66,
                                parent: :import_module
                              })

    save_edited_text.touch(true) do |val|

      grab(:importer_support).clear(true)
      parse_song_lyrics(@imported_lyrics)
      update_song_listing
      save_file("#{@title}.txt", @imported_lyrics)
    end
    edit_import = button({
                           label: :raw,
                           id: :edit_import,
                           top: LyricsStyle.dimensions[:margin],
                           left: :auto,
                           right: 5,
                           parent: :import_module
                         })

    edit_import.touch(true) do |val|
      if @edit_lyrics_mode
        grab("edit_import_label").data(:raw)
        grab(:importer_support).clear(true)
        parse_song_lyrics(@imported_lyrics)
        @edit_lyrics_mode = false
      else
        grab("edit_import_label").data(:insert)
        grab(:importer_support).clear(true)
        text_to_edit = grab(:importer_support).text({ data: @imported_lyrics, edit: true })
        text_to_edit.keyboard(:down) do |native_event|
          @imported_lyrics = text_to_edit.data
        end
        @edit_lyrics_mode = true
      end
      update_song_listing
    end

    save_song = button({
                         label: :save,
                         id: :save,
                         top: 6,
                         left: 470,
                         right: LyricsStyle.dimensions[:margin],
                         parent: :bottom_bar
                       })
    save_song.touch(true) do

      update_song_listing
      content_to_save = @list
      list_tile = "#{@list_title}.prx"
      save_file(list_tile, content_to_save)
      save_file_to_db(list_tile, content_to_save)
    end
    load_prev_song = button({
                              label: 'prev.',
                              id: :load_prev_song,
                              top: 6,
                              left: 535,
                              right: LyricsStyle.dimensions[:margin],
                              parent: :bottom_bar
                            })

    load_prev_song.touch(true) do
      play_next_song({ prev: true, immediate: true })
    end

    load_next_song = button({
                              label: :next,
                              id: :load_next_song,
                              top: 6,
                              left: 593,
                              right: LyricsStyle.dimensions[:margin],
                              parent: :bottom_bar
                            })

    load_next_song.touch(true) do

      play_next_song({ immediate: true })
    end

    load_song = button({
                         label: :load,
                         id: :load,
                         top: 6,
                         left: 410,
                         right: 65,
                         parent: :bottom_bar
                       })

    load_song.touch(true) do

      if grab(:loader)
        hide_all_panels
      else
        hide_all_panels
        grab(:main_line).box({ id: :loader,
                               width: 259,
                               height: 333,
                               smooth: 9,
                               shadow: LyricsStyle.decorations[:shadow] })
        load_file = button({
                             label: :disk,
                             id: :disk_loader,
                             top: 3,
                             left: 3,
                             right: 65,
                             parent: :loader,

                           })
        load_file.import(true) do |val|
          current_lyricist = grab(:the_lyricist).data
          current_lyricist.load_strategy(val)

        end

        result = list_all_files_in_localstorage
        result[:files].each_with_index do |file, index|
          list_f = grab(:loader).text(file)
          list_f.position(:absolute)
          list_f.left(5)
          list_f.top((25 * index) + 39)
          list_f.touch(true) do
            file_content = load_file(file)
            current_lyricist = grab(:the_lyricist).data
            list_to_load = { filename: file.to_s, content: file_content.to_s }
            current_lyricist.load_strategy(list_to_load)
          end
        end
      end

    end

    song_title = button({
                          label: @title,
                          id: :title,
                          top: LyricsStyle.dimensions[:margin],
                          left: 250+25,
                          width: 120,
                          edit: true,
                          parent: :tool_bar
                        })
    song_title.keyboard(:down) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13'
        song_title.blink(:orange)
        event.preventDefault
        title = grab('title_label')
        @title = title.data
      end
    end
  end
end