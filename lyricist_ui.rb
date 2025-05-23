# frozen_string_literal: true

class Lyricist < Atome
  def build_ui
    build_tool_bar
    build_song_support
    build_control_buttons
    build_lyrics_viewer
    prepare_lyrics_display
    build_timeline_slider
  end

  def build_lyrics_viewer

    button({
             label: '',
             id: :counter_support,
             width: 99,
             left: LyricsStyle.positions[:counter_left]+25,
             top: LyricsStyle.dimensions[:margin],
             parent: :tool_bar,

           })
    grab(:counter_support).overflow(:hidden)
    counter = grab(:counter_support).text({
                                            data: 0,
                                            content: :play,
                                            left: 6,
                                            color: LyricsStyle.colors[:secondary],
                                            top: 6,
                                            position: :absolute,
                                            id: :counter,
                                            invert: true
                                          })

    # base_text = ''

    lyrics_support = grab(:main_stage).box({
                                             id: :lyrics_support,
                                             width: :auto,
                                             height: :auto,
                                             top: LyricsStyle.dimensions[:tool_bar_height],
                                             left: 0,
                                             right: 0,
                                             bottom: 0,
                                             overflow: :scroll,
                                             color: LyricsStyle.colors[:container_bg]
                                           })

    lyrics_support.touch(:long) do

      fullscreen

    end

    counter.timer({ position: 88 })

  end

  def setup_lyrics_events
    lyrics = grab(:main_line)

    lyrics.keyboard(:down) do |native_event|

      event = Native(native_event)
      if event[:keyCode].to_s == '13'
        grab(:counter).content(:play)
        event.preventDefault
        alter_lyric_event
        update_song_listing

      end
    end
  end

  def build_song_support
    grab(:lyrics_support).box({
                                id: :import_module,
                                top: LyricsStyle.dimensions[:tool_bar_height],
                                left: :auto,
                                right: 0,
                                width: 399,
                                bottom: 50,
                                height: :auto,
                                smooth: LyricsStyle.decorations[:standard_smooth],
                                color: LyricsStyle.colors[:container_bg],
                                shadow: LyricsStyle.decorations[:shadow],
                                depth: 2,
                              })

    support = grab(:import_module).box({
                                         id: :importer_support,
                                         overflow: :auto,
                                         top: 39,
                                         left: 3,
                                         bottom: 3,
                                         right: 3,
                                         height: :auto,
                                         width: :auto,
                                         smooth: LyricsStyle.decorations[:standard_smooth],
                                         color: LyricsStyle.colors[:container_medium],
                                       })

    support.shadow(LyricsStyle.decorations[:invert_shadow])

    importer do |val|
      content = val[:content]
      filename = val[:name]
      current_lyricist = grab(:the_lyricist).data
      formated_import = { content: content, filename: filename }
      current_lyricist.load_strategy(formated_import)
    end
  end

  def build_timeline_slider
    lyrics = grab(:main_line)
    counter = grab(:counter)
    grab(:main_stage).slider(
      LyricsStyle.slider_style({
                                 id: :timeline_slider,
                                 attach: :bottom_bar,
                                 range: { color: :orange },
                                 min: 0,
                                 max: @length,
                                 width: LyricsStyle.dimensions[:slider_width],
                                 value: 0,
                                 height: LyricsStyle.dimensions[:slider_height],
                                 left: 25,
                                 tag: [],
                                 top: 6,
                                 color: :orange,
                                 cursor: { color: :orange, width: 25, height: 25 }
                               })
    ) do |value|
      counter.data(value)
      update_lyrics(value, lyrics)
      @actual_position = value

    end
    grab(:timeline_slider_cursor).touch(:down) do
      grab(:counter).timer({ pause: true })
      stop_audio(@audio_object)
    end
    grab(:timeline_slider_cursor).touch(:up) do
      if @playing
        play_audio(@audio_object, @actual_position)
      end
    end
  end

  def build_tool_bar
    tool_bar = grab(:main_stage).box({
                                       id: :tool_bar,
                                       color: LyricsStyle.colors[:container_bg],
                                       shadow: LyricsStyle.decorations[:standard_shadow],
                                       top: 5,
                                       left: 0,
                                       right: 0,
                                       width: :auto,
                                       height: LyricsStyle.dimensions[:tool_bar_height],
                                       opacity: 1,
                                       depth: 3,
                                       overflow: :auto
                                       # drag: true
                                     })

    bottom_bar = grab(:main_stage).box({
                                         id: :bottom_bar,
                                         color: LyricsStyle.colors[:container_bg],
                                         shadow: LyricsStyle.decorations[:standard_shadow],
                                         top: :auto,
                                         bottom: 5,
                                         left: 0,
                                         right: 0,
                                         width: :auto,
                                         height: LyricsStyle.dimensions[:tool_bar_height],
                                         opacity: 1,
                                         depth: 3,
                                         overflow: :auto
                                         # drag: true
                                       })

    tool_bar.touch(:double) do
      hide_all_panels
    end

    bottom_bar.touch(:double) do
      hide_all_panels
    end

    tool_bar.touch(:long) do
      fullscreen
    end

    bottom_bar.touch(:long) do
      fullscreen
    end
  end

  def update_song_listing
    current_song = (find_key_by_title(@list, @title))
    if current_song
      delete_song_from_list(current_song)

      add_current_song_to_list(current_song)
    else
      add_current_song_to_list
    end
    refresh_song_list
  end

end