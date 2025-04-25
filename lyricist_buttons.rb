# frozen_string_literal: true

class Lyricist < Atome
  def button(params)
    id_f = params[:id] || identity_generator
    width_f = params[:width] || LyricsStyle.dimensions[:standard_width]
    height_f = params[:height] || LyricsStyle.dimensions[:button_height]
    top_f = params[:top] || 0
    left_f = params[:left] || 0
    background_f = params[:background] || LyricsStyle.colors[:primary]
    color_f = params[:color] || :black
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
                                 color: background_f
                               })
    )

    btn.text(
      LyricsStyle.text_style({
                               data: label_f,
                               component: { size: size_f },
                               top: 5,
                               left: 3,
                               color: color_f
                             })
    )

    btn
  end

  def build_control_buttons

    # Bouton Start
    start = button({
                     label: :start,
                     id: :start,
                     color: LyricsStyle.colors[:primary]
                   })

    start.touch(true) do
      counter = grab(:counter)

      prev_length = @length
      counter.timer({ end: 99999999999 }) do |value|
        lyrics = grab(:lyric_viewer)
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

    # Bouton Erase
    erase = button({
                     id: :erase,
                     color: :red,
                     background: :yellow,
                     label: :erase,
                     left: LyricsStyle.positions[:second_column]
                   })

    erase.touch(true) do
      clear_all
    end

    ###########

    clear = button({
                     label: 'clear',
                     id: :clear,
                     top: 66,
                     left: 120,
                     color: :yellow,
                     background: :red,
                     left: LyricsStyle.positions[:second_column]
                   })

    clear.touch(true) do
      # clear_all
      grab(:importer_support).clear(true)
    end
    ###########

    # Bouton Stop
    stop = button({
                    label: :stop,
                    id: :stop,
                    color: LyricsStyle.colors[:secondary],
                    left: LyricsStyle.positions[:third_column]
                  })

    stop.touch(true) do
      counter = grab(:counter)
      counter.timer({ stop: true })
      lyrics = grab(:lyric_viewer)
      update_lyrics(0, lyrics, counter)
      grab(:timeline_slider).delete({ force: true })
      build_timeline_slider
    end

    # Bouton Pause
    pause = button({
                     label: :pause,
                     color: LyricsStyle.colors[:accent],
                     text_color: :black,
                     left: LyricsStyle.positions[:fourth_column]
                   })

    pause.touch(true) do
      grab(:counter).timer({ pause: true })
    end
    import_lyrics = button({
                             label: :import,
                             id: :import_lyrics,
                             color: LyricsStyle.colors[:accent],
                             text_color: :black,
                             top: 66,
                             left: LyricsStyle.positions[:fourth_column]
                           })

    import_lyrics.import(true) do |val|
      parse_song_lyrics(val)
    end
    # importer do |val|
    #   parse_song_lyrics(val[:content])
    # end

  end

  def build_record_button
    record = button({
                      label: 'rec.',
                      id: :rec_box,
                      top: 30,
                      left: 0,
                      text_color: :white
                    })

    rec_color = grab(:view).color({ id: :rec_color, red: 1, alpha: 0.6 })
    record.apply(:rec_color)

    record.touch(true) do
      prev_postion = @actual_position
      lyric_viewer = grab(:lyric_viewer)
      if @record == true
        @record = false
        lyric_viewer.edit(false)
        rec_color.alpha(0.6)
        @number_of_lines = @original_number_of_lines
      else
        @record = true
        rec_color.alpha(1)
        lyric_viewer.edit(true)
        @number_of_lines = 1
        counter = grab(:counter)
        lyrics = grab(:lyric_viewer)
        update_lyrics(0, lyrics, counter)
      end
      full_refresh_viewer(prev_postion)
    end
  end



  def build_editor_controls
    prev_word = button({
                         label: :prev,
                         id: :prev,
                         left: LyricsStyle.positions[:fifth_column]
                       })

    next_word = button({
                         label: :next,
                         id: :next,
                         left: LyricsStyle.positions[:sixth_column]
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
  end

  def build_navigation_buttons
    prev_word = button({
                         label: :prev,
                         id: :prev,
                         left: LyricsStyle.positions[:fifth_column]
                       })

    next_word = button({
                         label: :next,
                         id: :next,
                         left: LyricsStyle.positions[:sixth_column]
                       })

    prev_word.touch(true) do
      alert (:lyric_viewer).content
      # cf : update_lyrics
    end
  end

  def build_lyrics_editor_button
    # Création du bouton d'édition des paroles
    edit_lyrics = button({
                           label: "Edit",
                           id: :edit_lyrics_button,
                           # width: LyricsStyle.dimensions[:medium_width],
                           # height: LyricsStyle.dimensions[:medium_height],
                           left: LyricsStyle.positions[:seventh_column],
                           top: LyricsStyle.positions[:second_row],
                           # color: LyricsStyle.colors[:info],
                           text_color: :yellow,
                           size: LyricsStyle.dimensions[:text_medium]
                         })

    edit_lyrics.touch(true) do
      if @editor_open
        # Fermer l'éditeur s'il est déjà ouvert
        grab(:lyrics_editor_container).delete({ recursive: true }) if grab(:lyrics_editor_container)
        @editor_open = false
      else
        # Ouvrir l'éditeur
        @editor_open = true
        show_lyrics_editor(LyricsStyle.positions[:editor_default_left], LyricsStyle.positions[:editor_default_top])
      end
    end
  end

  private

  def identity_generator
    # Génère un ID unique
    "button_#{Time.now.to_i}_#{rand(1000)}".to_sym
  end
end