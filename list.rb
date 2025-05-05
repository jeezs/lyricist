# Lyricist class
class Lyricist

  def build_list_manager
    list_button = button({
                           label: :list,
                           id: :list_button,
                           top: LyricsStyle.dimensions[:margin],
                           left: LyricsStyle.positions[:seventh_column]+25,
                           parent: :tool_bar
                         })

    grab('main_stage').box({
                             id: :list_panel,
                             width: 400,
                             bottom: 50,
                             top: 0,
                             height: :auto,
                             left: 0,
                             color: LyricsStyle.colors[:background],
                             depth: 10,
                             overflow: :auto,
                             display: :none,
                             attach: :lyrics_support
                           })

    list_title_bar = grab('list_title_bar').box({
                                                  id: :list_title_bar,
                                                  width: 400,
                                                  height: 39,
                                                  top: 0,
                                                  left: 0,
                                                  color: LyricsStyle.colors[:primary],
                                                  attach: :list_panel,
                                                  shadow: LyricsStyle.decorations[:shadow]

                                                })
    grab('list_title_bar').box({
                                 id: :list_bottom_bar,
                                 width: 400,
                                 height: 39,
                                 top: :auto,
                                 bottom: 0,
                                 left: 0,
                                 color: LyricsStyle.colors[:primary],
                                 attach: :list_panel,
                                 shadow: LyricsStyle.decorations[:shadow]
                               })

    title_bar_list_text = list_title_bar.text({ id: :list_title,
                                                position: :absolute, top: LyricsStyle.dimensions[:margin] * 3,
                                                left: LyricsStyle.dimensions[:margin] * 3,
                                                data: 'List name', edit: true, color: LyricsStyle.colors[:secondary] })
    @list_title = 'new list'
    title_bar_list_text.keyboard(:down) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13'
        @list_title = title_bar_list_text.data
        title_bar_list_text.blink(:orange)
        event.preventDefault
      end
    end

    grab('main_stage').text({
                              content: "Playlist Manager",
                              id: :list_panel_title,
                              width: 300,
                              height: 30,
                              top: 10,
                              left: 10,
                              size: LyricsStyle.dimensions[:text_medium],
                              color: :white,
                              attach: :list_title_bar
                            })

    grab('main_stage').box({
                             id: :list_container,
                             width: 380,
                             height: :auto,
                             top: 39,
                             bottom: 39,
                             left: 10,
                             overflow: :auto,

                             color: { alpha: 0 },
                             # color: :white,
                             attach: :list_panel
                           })

    add_song = button({
                        label: :new,
                        id: :add_song_to_list,
                        top: :auto,
                        bottom: 3,
                        left: 10,
                        parent: :list_bottom_bar,
                      })

    save_list = button({
                         label: "Save",
                         id: :save_list,
                         top: :auto,
                         bottom: 3,
                         left: :auto,
                         right: 10,
                         parent: :list_bottom_bar
                       })

    list_button.touch(true) do
      if grab(:list_panel).display == :none
        grab(:list_panel).display(:block)
        grab(:import_module).display(:none)
        grab(:lyrics_editor_container).delete({ recursive: true }) if grab(:lyrics_editor_container)
        refresh_song_list
      else
        grab(:list_panel).display(:none)
      end
      update_song_listing
    end

    add_song.touch(true) do
      add_current_song_to_list
      refresh_song_list
    end

    save_list.touch(true) do
      save_playlist
    end
  end

  def refresh_song_list
    list_container = grab(:list_container)
    list_container.clear(true)

    return unless @list && !@list.empty?

    current_list = @list.dup

    sorted_keys = current_list.keys.sort_by { |k| k.to_i }

    top_position = 10

    sorted_keys.each do |key|
      item = current_list[key]
      next unless item && item["title"]

      song_item = grab('main_stage').box({
                                           id: "song_item_#{key}",
                                           width: 360,
                                           height: 50,
                                           top: top_position,
                                           left: 0,
                                           smooth: 6,
                                           color: LyricsStyle.colors[:primary],
                                           attach: :list_container
                                         })

      grab('main_stage').text({
                                data: key.to_s,
                                id: "order_#{key}",
                                height: 30,
                                position: :absolute,
                                top: 10,
                                left: 10,
                                edit: true,
                                color: :lightgray,
                                attach: "song_item_#{key}"
                              })

      grab('main_stage').text({
                                data: item["title"].to_s,
                                id: "title_#{key}",
                                width: 200,
                                position: :absolute,
                                height: 30,
                                top: 10,
                                left: 50,
                                color: :lightgray,
                                attach: "song_item_#{key}"
                              })

      load_button = button({
                             label: "Load",
                             id: "load_#{key}",
                             top: 10,
                             left: 260,
                             width: 40,
                             height: 30,
                             size: LyricsStyle.dimensions[:text_small],
                             parent: "song_item_#{key}"
                           })

      delete_button = button({
                               label: "X",
                               id: "delete_#{key}",
                               top: 10,
                               left: 310,
                               width: 30,
                               height: 30,
                               size: LyricsStyle.dimensions[:text_small],
                               color: LyricsStyle.colors[:danger],
                               parent: "song_item_#{key}"
                             })

      load_button.touch(true) do
        title_to_load = item["title"].to_s
        new_key = find_song_key_by_title(title_to_load)
        load_song_from_list(new_key) if new_key
        grab(:list_panel).display(:none)

      end

      song_item.touch(true) do
        title_to_load = item["title"].to_s
        new_key = find_song_key_by_title(title_to_load)
        load_song_from_list(new_key) if new_key
        grab(:list_panel).display(:none)

      end

      delete_button.touch(true) do
        title_to_delete = item["title"].to_s
        new_key = find_song_key_by_title(title_to_delete)

        if new_key
          delete_song_from_list(new_key)
          refresh_song_list
        end
      end

      grab("order_#{key}").keyboard(:down) do |native_event|
        event = Native(native_event)
        if event[:keyCode].to_s == '13' # Touche Entrée
          title_to_reorder = item["title"].to_s
          new_key = find_song_key_by_title(title_to_reorder)
          new_order = grab("order_#{key}").data

          if new_key
            reorder_song(new_key, new_order)
            refresh_song_list
            update_song_listing
          end

          event.preventDefault
        end
      end

      top_position += 60
    end
  end

  def find_song_key_by_title(title)
    return nil unless @list

    @list.each do |key, item|
      return key if item && item["title"].to_s == title
    end

    nil
  end

  def load_song_from_list(key)

    return unless @list && @list[key]

    prepare_lyrics_display
    song_data = @list[key]

    stop_audio(@audio_object) if @audio_object
    @title = song_data["title"]
    grab('title_label').data(@title) if grab('title_label')

    init_audio(song_data["song"])

    lyrics = eval(song_data["lyrics"]) rescue {}
    grab(:main_line).content(lyrics) if grab(:main_line)

    (1...@number_of_lines).each do |index|
      grab("my_line_#{index}").data('') if grab("my_line_#{index}")
    end

    raw_text = song_data[:raw]

    grab(:importer_support).clear(true)
    parse_song_lyrics(raw_text)
    @imported_lyrics = raw_text

    full_refresh_viewer(0)

  end

  def delete_song_from_list(key)
    return unless @list && @list[key]

    @list[key]["title"] rescue "inconnu"

    @list.delete(key)

  end

  def reorder_song(old_key, new_key)
    return unless @list && @list[old_key]
    return if old_key == new_key

    song_data = @list[old_key]

    @list.delete(old_key)

    @list[new_key] = song_data

    reorder_all_songs
  end

  def reorder_all_songs
    sorted_items = @list.to_a.sort_by { |k, _| k.to_i }

    sorted_items.map { |k, _| k }

    key_mapping = {}

    sorted_items.each_with_index do |(old_key, item), index|
      new_key = (index + 1).to_s
      key_mapping[old_key] = new_key

      next if old_key == new_key

      @list[new_key] = item

      @list.delete(old_key) if old_key != new_key
    end

    refresh_song_list
  end

  def add_current_song_to_list(song_nb = nil)
    return unless @audio_path && @title

    current_lyrics = grab(:main_line).content.to_s rescue "{}"

    # Créer une nouvelle entrée
    new_song = {
      "lyrics" => current_lyrics,
      "song" => @audio_path,
      "title" => @title,
      "raw" => @imported_lyrics

    }

    next_key = @list.empty? ? "1" : (@list.keys.map(&:to_i).max + 1).to_s

    if song_nb
      @list[song_nb] = new_song
    else
      @list[next_key] = new_song
    end

  end

  def save_playlist
    update_song_listing
    content_to_save = @list
    list_tile = "#{@list_title}.prx"
    save_file(list_tile, content_to_save)
  end

  def load_playlist(file_content)
    playlist_data = eval(file_content) rescue {}
    if playlist_data.is_a?(Hash) && !playlist_data.empty?
      @list = playlist_data
      refresh_song_list
    end
  end

  def initialize_list_manager
    build_list_manager
  end

end
