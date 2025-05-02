# frozen_string_literal: true

class Lyricist < Atome
  # Construction de l'interface utilisateur
  def build_ui
    build_tool_bar
    build_song_support
    build_control_buttons
    build_lyrics_viewer
    build_timeline_slider
  end

  def build_lyrics_viewer

    button({
             label: '',
             id: :counter_support,
             width: 99,
             left: LyricsStyle.positions[:counter_left],
             # color: LyricsStyle.colors[:secondary],
             top: LyricsStyle.dimensions[:margin],
             # position: :absolute,
             parent: :tool_bar
           })

    counter = grab(:counter_support).text({
                                            data: :counter,
                                            content: :play,
                                            # center: true,
                                            left: 6,
                                            color: LyricsStyle.colors[:secondary],
                                            top: 6,
                                            position: :absolute,
                                            id: :counter,
                                            invert: true
                                          })

    base_text = ''

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

    lyrics_support.text({
                          top: 3,
                          left: 3,
                          width: LyricsStyle.dimensions[:line_width],
                          data: base_text,
                          id: :lyric_viewer,
                          edit: false,
                          component: { size: LyricsStyle.dimensions[:text_xlarge] },
                          position: :absolute,
                          content: { 0 => base_text },
                          context: :insert
                        })

    lyrics_support.touch(true) do
      hide_all_panels
    end

    lyrics_support.touch(:long) do

      top_f = lyrics_support.top
      if top_f == 0
        lyrics_support.left(0)
        lyrics_support.right(0)
        lyrics_support.top(LyricsStyle.dimensions[:tool_bar_height])
        lyrics_support.width(:auto)
        lyrics_support.height(:auto)
        lyrics_support.depth = 0
      else
        lyrics_support.depth(7)
        lyrics_support.left(0)
        lyrics_support.top(0)
        lyrics_support.bottom(0)
        lyrics_support.right(0)
        lyrics_support.width(:auto)
        lyrics_support.height(:auto)
        lyrics_support.depth = 99
      end

    end

    counter.timer({ position: 88 })

    # Événements sur le viewer de paroles
    setup_lyrics_events
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
                      # drag: true,
                      # resize: true,
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
                                         color: LyricsStyle.colors[:container_light],
                                       })

    support.shadow(LyricsStyle.decorations[:invert_shadow])

    importer do |val|
      content = val[:content]
      filename = val[:name]
      current_lyricist = grab(:the_lyricist).data
      formated_import = { content: content, filename: filename }
      current_lyricist.load_strategy(formated_import)
      # grab(:importer_support).clear(true)
      # parse_song_lyrics(val[:content])
    end
  end

  def build_timeline_slider
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
                                 left: LyricsStyle.dimensions[:margin]+33,
                                 tag: [],
                                 top: LyricsStyle.dimensions[:margin] ,
                                 # bottom: LyricsStyle.dimensions[:margin] * 3,
                                 color: :orange,
                                 cursor: { color: :orange, width: 25, height: 25 }

                               })
    ) do |value|
      lyrics = grab(:lyric_viewer)
      counter = grab(:counter)
      update_lyrics(value, lyrics, counter)
    end
    grab(:timeline_slider_cursor).touch(:down) do
      grab(:counter).timer({ pause: true })
      # @playing = false
      stop_audio(@audio_object)
    end
    grab(:timeline_slider_cursor).touch(:up) do

      counter = grab(:counter)
      if @playing
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
      end
    end
  end

  def build_tool_bar
    grab(:main_stage).box({
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

    grab(:main_stage).box({
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
  end

  def update_song_listing
    current_song = (find_key_b◊y_title(@list, @title))
    if current_song
      delete_song_from_list(current_song)

      add_current_song_to_list(current_song)
      # refresh_song_list
    else
      add_current_song_to_list
      # refresh_song_list
    end
    # wait 0.5 do
      refresh_song_list
  # end
end

  def setup_lyrics_events
    lyrics = grab(:lyric_viewer)

    lyrics.keyboard(:down) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13' # Touche Entrée
        grab(:counter).content(:play) # Permet la mise à jour du viewer de paroles pendant la lecture
        event.preventDefault
        alter_lyric_event

        #### updating the list
        update_song_listing

      end
    end
  end
end