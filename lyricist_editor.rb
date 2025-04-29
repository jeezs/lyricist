# frozen_string_literal: true
class Lyricist < Atome
  def show_lyrics_editor(left_f, top_f)
    # Conteneur principal pour l'éditeur
    editor_container = grab(:view).box(
      LyricsStyle.container_style({
                                    id: :lyrics_editor_container,
                                    top: top_f,
                                    left: left_f,
                                    position: :absolute,
                                    overflow: :auto,
                                    #drag: true,
                                    # resize: true,
                                    depth: 4
                                  })
    )

    # Titre de l'éditeur
    editor_container.text(
      LyricsStyle.text_style({
                               data: "Lyrics editor",
                               component: { size: LyricsStyle.dimensions[:text_large] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 33,
                               top: 10,

                             })
    )

    # Bouton pour fermer l'éditeur
    # close_button = editor_container.box(
    #   LyricsStyle.action_button_style({
    #                                     width: 25,
    #                                     height: 25,
    #                                     right: 10,
    #                                     top: 10,
    #                                     color: LyricsStyle.colors[:danger]
    #                                   })
    # )

    # close_button.text(
    #   LyricsStyle.text_style({
    #                            data: "X",
    #                            component: { size: LyricsStyle.dimensions[:text_small] },
    #                            color: LyricsStyle.colors[:text_primary],
    #                            left: 8,
    #                            top: 3
    #                          })
    # )

    # close_button.touch(true) do
    #   editor_container.delete({ recursive: true })
    #   @editor_open = false
    # end

    # Récupération et tri des paroles
    lyrics = grab(:lyric_viewer)
    sorted_lyrics = lyrics.content.sort.to_h

    # Affichage des paroles avec options d'édition
    sorted_lyrics.each_with_index do |(timecode, text), index|
      y_position = 50 + (index * 60)

      # Conteneur pour chaque ligne
      line_container = editor_container.box(
        LyricsStyle.line_container_style({
                                           id: "line_container_#{index}".to_sym,
                                           top: y_position
                                         })
      )

      # Champ pour le timecode
      timecode_field = line_container.text(
        LyricsStyle.text_style({
                                 id: "timecode_#{index}".to_sym,
                                 data: timecode.to_s,
                                 component: { size: LyricsStyle.dimensions[:text_normal] },
                                 edit: true,
                                 width: 70,
                                 left: 10,
                                 top: 10,
                                 color: LyricsStyle.colors[:text_primary]
                               })
      )

      # Champ pour le texte
      text_field = line_container.text(
        LyricsStyle.text_style({
                                 id: "text_#{index}".to_sym,
                                 data: text.to_s,
                                 component: { size: LyricsStyle.dimensions[:text_normal] },
                                 edit: true,
                                 width: 300,
                                 left: 90,
                                 top: 10,
                                 color: LyricsStyle.colors[:text_primary]
                               })
      )

      # Actions
      setup_edit_line_events(line_container, timecode_field, text_field, timecode, lyrics)

      # Bouton de mise à jour
      update_button = build_update_button(line_container, timecode, timecode_field, text_field, lyrics)

      # Bouton de suppression
      delete_button = build_delete_button(line_container, editor_container, timecode, lyrics)
    end

    # Bouton pour ajouter une nouvelle ligne
    build_add_line_button(editor_container, sorted_lyrics, lyrics)
  end

  private

  def setup_edit_line_events(line_container, timecode_field, text_field, timecode, lyrics)
    # Action sur le champ timecode
    timecode_field.keyboard(:dowm) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13'
        alert 'case2'
        event.preventDefault
        old_timecode = timecode
        new_timecode = timecode_field.data.to_i
        new_text = text_field.data

        if new_timecode != old_timecode
          lyrics.content.delete(old_timecode)
          lyrics.content[new_timecode] = new_text
        else
          lyrics.content[old_timecode] = new_text
        end

        line_container.blink(LyricsStyle.colors[:success])
        counter = grab(:counter)
        current_position = counter.timer[:position]
        update_lyrics(current_position, lyrics, counter)

        max_timecode = lyrics.content.keys.max
        if max_timecode > @length
          @length = max_timecode
          full_refresh_viewer(current_position)
        end
        prev_position = @actual_position
        full_refresh_viewer(prev_position)
      end
    end

    # Action sur le champ texte
    text_field.keyboard(:dowm) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13'
        alert 'case5'

        event.preventDefault
        old_timecode = timecode
        new_timecode = timecode_field.data.to_i
        new_text = text_field.data

        if new_timecode != old_timecode
          lyrics.content.delete(old_timecode)
          lyrics.content[new_timecode] = new_text
        else
          lyrics.content[old_timecode] = new_text
        end

        line_container.blink(LyricsStyle.colors[:success])
        counter = grab(:counter)
        current_position = counter.timer[:position]
        update_lyrics(current_position, lyrics, counter)

        max_timecode = lyrics.content.keys.max
        if max_timecode > @length
          @length = max_timecode
          full_refresh_viewer(current_position)
        end
        prev_position = @actual_position
        full_refresh_viewer(prev_position)
      end
    end
  end

  def build_update_button(line_container, timecode, timecode_field, text_field, lyrics)
    update_button = line_container.box(
      LyricsStyle.action_button_style({
                                        width: 25,
                                        height: 25,
                                        left: 400,
                                        top: 10,
                                        color: LyricsStyle.colors[:success]
                                      })
    )

    update_button.text(
      LyricsStyle.text_style({
                               data: "✓",
                               component: { size: LyricsStyle.dimensions[:text_small] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 7,
                               top: 5
                             })
    )

    update_button.touch(true) do
      alert 'case7'
      old_timecode = timecode
      new_timecode = timecode_field.data.to_i
      new_text = text_field.data

      if new_timecode != old_timecode
        # Si le timecode a changé, on supprime l'ancien et on ajoute le nouveau
        lyrics.content.delete(old_timecode)
        lyrics.content[new_timecode] = new_text
      else
        # Sinon on met simplement à jour le texte
        lyrics.content[old_timecode] = new_text
      end

      # Notification visuelle de mise à jour
      line_container.blink(LyricsStyle.colors[:success])

      # Mise à jour de l'affichage et du slider si nécessaire
      counter = grab(:counter)
      current_position = counter.timer[:position]
      update_lyrics(current_position, lyrics, counter)

      # Reconstruire le slider si la plage a changé
      max_timecode = lyrics.content.keys.max
      if max_timecode > @length
        @length = max_timecode
        full_refresh_viewer(current_position)
      end
      prev_position = @actual_position
      full_refresh_viewer(prev_position)
    end

    update_button
  end

  def build_delete_button(line_container, editor_container, timecode, lyrics)
    delete_button = line_container.box(
      LyricsStyle.action_button_style({
                                        width: 25,
                                        height: 25,
                                        left: 435,
                                        top: 10,
                                        color: LyricsStyle.colors[:danger]
                                      })
    )

    delete_button.text(
      LyricsStyle.text_style({
                               data: "✗",
                               component: { size: LyricsStyle.dimensions[:text_small] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 7,
                               top: 5
                             })
    )

    delete_button.touch(true) do
      alert 'case1'
      prev_left = editor_container.left
      prev_top = editor_container.top
      lyrics.content.delete(timecode)

      line_container.delete({ recursive: true })

      # Réorganiser les éléments restants
      editor_container.delete({ recursive: true })
      show_lyrics_editor(prev_left, prev_top)

      # Mise à jour de l'affichage
      counter = grab(:counter)
      current_position = counter.timer[:position]
      update_lyrics(current_position, lyrics, counter)

      # Reconstruire le slider
      full_refresh_viewer(current_position)
    end

    delete_button
  end

  def build_add_line_button(editor_container, sorted_lyrics, lyrics)
    add_button = editor_container.box(
      LyricsStyle.line_container_style({
                                         width: 520,
                                         height: 40,
                                         left: 10,
                                         top: 50 + (sorted_lyrics.size * 60),
                                         color: LyricsStyle.colors[:success]
                                       })
    )

    add_button.text(
      LyricsStyle.text_style({
                               data: "+ Add a new line",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 160,
                               top: 10
                             })
    )

    add_button.touch(true) do
      show_add_dialog(editor_container, lyrics)
    end

    add_button
  end

  def show_add_dialog(editor_container, lyrics)
    # Ouvrir un dialogue pour ajouter une nouvelle ligne
    dialog_container = grab(:lyrics_editor_container).box(
      LyricsStyle.container_style({
                                    id: :add_dialog,
                                    width: 300,
                                    height: 150,
                                    left: 120,
                                    top: 120,
                                    position: :absolute
                                  })
    )

    dialog_container.text(
      LyricsStyle.text_style({
                               data: "Add a new line",
                               component: { size: LyricsStyle.dimensions[:text_large] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 10,
                               top: 10
                             })
    )

    # Champ pour le nouveau timecode
    dialog_container.text(
      LyricsStyle.text_style({
                               data: "Timecode:",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 10,
                               top: 40
                             })
    )

    new_timecode_field = dialog_container.text(
      LyricsStyle.text_style({
                               id: :new_timecode,
                               data: 120,
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               edit: true,
                               width: 200,
                               left: 90,
                               top: 40,
                               color: LyricsStyle.colors[:text_accent]
                             })
    )

    new_timecode_field.keyboard(:down) do |native_event|
      event = Native(native_event)

      if event[:keyCode].to_s == '13' # Touche Entrée
        event.preventDefault
      end
    end

    # Champ pour le nouveau texte
    dialog_container.text(
      LyricsStyle.text_style({
                               data: "Texte:",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 10,
                               top: 70
                             })
    )

    new_text_field = dialog_container.text(
      LyricsStyle.text_style({
                               id: :new_text,
                               data: "Dummy text",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               edit: true,
                               width: 200,
                               left: 90,
                               top: 70,
                               color: LyricsStyle.colors[:text_primary]
                             })
    )

    new_text_field.keyboard(:down) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13' # Touche Entrée
        event.preventDefault
      end
    end

    # Boutons d'action
    build_dialog_buttons(dialog_container, new_timecode_field, new_text_field, editor_container, lyrics)
  end

  def build_dialog_buttons(dialog_container, new_timecode_field, new_text_field, editor_container, lyrics)
    # Bouton de confirmation
    confirm_button = dialog_container.box(
      LyricsStyle.action_button_style({
                                        width: LyricsStyle.dimensions[:large_width],
                                        height: 30,
                                        left: 30,
                                        top: 110,
                                        color: LyricsStyle.colors[:success]
                                      })
    )

    confirm_button.text(
      LyricsStyle.text_style({
                               data: "Confirmer",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 30,
                               top: 5
                             })
    )

    # Bouton d'annulation
    cancel_button = dialog_container.box(
      LyricsStyle.action_button_style({
                                        width: LyricsStyle.dimensions[:large_width],
                                        height: 30,
                                        left: 160,
                                        top: 110,
                                        color: :gray
                                      })
    )

    cancel_button.text(
      LyricsStyle.text_style({
                               data: "Annuler",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 35,
                               top: 5
                             })
    )

    # Action de confirmation
    confirm_button.touch(true) do
      alert 'case6'
      prev_left = editor_container.left
      prev_top = editor_container.top
      new_timecode = new_timecode_field.data.to_i
      new_text = new_text_field.data

      if new_timecode > 0 && !new_text.empty?
        lyrics.content[new_timecode] = new_text

        # Mise à jour de l'affichage
        counter = grab(:counter)
        current_position = counter.timer[:position]
        update_lyrics(current_position, lyrics, counter)

        # Mettre à jour la longueur si nécessaire
        if new_timecode > @length
          @length = new_timecode
        end

        # Reconstruire le slider et l'éditeur
        full_refresh_viewer(current_position)
        dialog_container.delete({ recursive: true })
        editor_container.delete({ recursive: true })
        show_lyrics_editor(prev_left, prev_top)
      else
        # Notification d'erreur
        dialog_container.blink(LyricsStyle.colors[:danger])
      end
    end

    cancel_button.touch(true) do
      dialog_container.delete({ recursive: true })
    end
  end
end