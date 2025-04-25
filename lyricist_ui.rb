# frozen_string_literal: true

class Lyricist < Atome
  # Construction de l'interface utilisateur
  def build_ui
    build_tool_bar
    build_control_buttons
    build_lyrics_viewer
    build_song_support
    build_timeline_slider
  end

  def build_lyrics_viewer
    counter = grab(:view).text({
                                 data: :counter,
                                 content: :play,
                                 left: 60,
                                 top: LyricsStyle.positions[:third_row],
                                 position: :absolute,
                                 id: :counter,
                               })

    base_text = ''

    lyrics_support = grab(:view).box({
                                       id: :lyrics_support,
                                       width: 180,
                                       height: 180,
                                       top: LyricsStyle.positions[:fourth_row],
                                       left: 35,
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

    lyrics_support.touch(:double) do

      left_f = lyrics_support.left
      if left_f == 0
        lyrics_support.left(33)
        lyrics_support.top(120)
        lyrics_support.width(399)
        lyrics_support.height(150)
      else
        lyrics_support.depth(3)
        lyrics_support.left(0)
        lyrics_support.top(0)
        lyrics_support.bottom(0)
        lyrics_support.right(0)
        lyrics_support.width(:auto)
        lyrics_support.height(:auto)
      end

    end

    counter.timer({ position: 88 })

    # Événements sur le viewer de paroles
    setup_lyrics_events
  end

  def build_song_support
    support = grab(:view).box({
                                overflow: :auto,
                                top: 3,
                                left: :auto,
                                right: 9,
                                width: 399,
                                height: 600,
                                smooth: LyricsStyle.decorations[:standard_smooth],
                                color: LyricsStyle.colors[:container_light],
                                id: :importer_support
                              })

    support.shadow(LyricsStyle.decorations[:invert_shadow])

    importer do |val|
      parse_song_lyrics(val[:content])
    end
  end

  def build_timeline_slider
    grab(:view).slider(
      LyricsStyle.slider_style({
                                   id: :timeline_slider,
                                   range: { color: :orange },
                                   min: 0,
                                   max: @length,
                                   width: 666,
                                   value: 0,
                                   height: 25,
                                   left: 61,
                                   tag: [],
                                   top: :auto,
                                   bottom: 3,
                                   color: :orange,
                                   cursor: { color: :orange, width: 25, height: 25 }

                               })
    ) do |value|
      lyrics = grab(:lyric_viewer)
      counter = grab(:counter)
      update_lyrics(value, lyrics, counter)
    end
  end

  def build_tool_bar
    grab(:view).box({
                      id: :tool_bar,
                      color: LyricsStyle.colors[:container_bg],
                      shadow: LyricsStyle.decorations[:standard_shadow],
                      top: 333,
                      left: 0,
                      right: 0,
                      width: :auto,
                      height: 39,
                      opacity: 1,
                      drag: true
                    })
  end

  def setup_lyrics_events
    lyrics = grab(:lyric_viewer)

    lyrics.keyboard(:down) do |native_event|
      grab(:lyrics_support).color({ red: 1, id: :red_col })
      event = Native(native_event)
      if event[:keyCode].to_s == '13' # Touche Entrée
        grab(:lyrics_support).remove(:red_col)
        grab(:counter).content(:play) # Permet la mise à jour du viewer de paroles pendant la lecture
        event.preventDefault
        alter_lyric_event
      end
    end
  end
end