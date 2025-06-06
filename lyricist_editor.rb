# frozen_string_literal: true
class Lyricist < Atome
  def show_lyrics_editor(left_f, top_f)
    # Conteneur principal pour l'éditeur
    editor_container = grab(:lyrics_support).box(
      LyricsStyle.container_style({
                                    id: :lyrics_editor_container,
                                    # color: :red,
                                    color: { red: 0.12, green: 0.12, blue: 0.12, alpha: 0 },
                                    left: grab(:view).to_px(:width) - 530, # :cant" use auto it crash when removing the panal
                                    width: 530,
                                    right: 0,
                                    depth: 33
                                  })
    )
    editor_container.touch(true) do |evt|
      evt.stop_propagation
      evt.prevent_default
      evt.prev
      puts 'jjj'
    end
    lyrics = grab(:main_line)
    sorted_lyrics = lyrics.content.sort.to_h

    sorted_lyrics.each_with_index do |(timecode, text), index|
      y_position = 70 + (index * 60)

      line_container = editor_container.box(
        LyricsStyle.line_container_style({
                                           id: "line_container_#{index}".to_sym,
                                           top: y_position,
                                           color: { red: 0.1, green: 0.1, blue: 0.1 },
                                         })
      )

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

      setup_edit_line_events(line_container, timecode_field, text_field, timecode, lyrics)

      build_update_button(line_container, timecode, timecode_field, text_field, lyrics)

      build_delete_button(line_container, editor_container, timecode, lyrics)
    end

    build_add_line_button(editor_container, sorted_lyrics, lyrics)
  end

  private

  def setup_edit_line_events(line_container, timecode_field, text_field, timecode, lyrics)
    timecode_field.keyboard(:dowm) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13'
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

        prev_position = @actual_position
        full_refresh_viewer(prev_position)
        update_song_listing
      end
    end

    text_field.keyboard(:dowm) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13'

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
        update_song_listing
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
      update_song_listing
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

      prev_left = editor_container.left
      prev_top = editor_container.top
      lyrics.content.delete(timecode)

      line_container.delete({ recursive: true })

      editor_container.delete({ recursive: true })
      show_lyrics_editor(prev_left, prev_top)

      counter = grab(:counter)
      current_position = counter.timer[:position]
      update_lyrics(current_position, lyrics, counter)

      full_refresh_viewer(current_position)
      update_song_listing
    end

    delete_button
  end

  def build_add_line_button(editor_container, sorted_lyrics, lyrics)
    add_button = editor_container.box(
      LyricsStyle.line_container_style({
                                         width: 520,
                                         height: 40,
                                         left: 10,
                                         top: 15,
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
    dialog_container = grab(:lyrics_editor_container).box(
      LyricsStyle.container_style({
                                    id: :add_dialog,
                                    width: 300,
                                    height: 150,
                                    left: 120,
                                    top: 120,
                                    color: { red: 0.1, green: 0.1, blue: 0.1 },
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
                               data: 100,
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               edit: true,
                               width: 200,
                               left: 110,
                               top: 40,
                             })
    )

    new_timecode_field.keyboard(:down) do |native_event|
      event = Native(native_event)

      if event[:keyCode].to_s == '13'
        event.preventDefault
      end
    end

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

    build_dialog_buttons(dialog_container, new_timecode_field, new_text_field, editor_container, lyrics)
  end

  def build_dialog_buttons(dialog_container, new_timecode_field, new_text_field, editor_container, lyrics)
    confirm_button = dialog_container.box(
      LyricsStyle.action_button_style({
                                        width: LyricsStyle.dimensions[:large_width],
                                        height: 30,
                                        left: 3,
                                        top: 110,
                                        color: LyricsStyle.colors[:success]
                                      })
    )

    confirm_button.text(
      LyricsStyle.text_style({
                               data: "ok",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 30,
                               top: 5
                             })
    )

    cancel_button = dialog_container.box(
      LyricsStyle.action_button_style({
                                        width: LyricsStyle.dimensions[:large_width],
                                        height: 30,
                                        left: 150,
                                        top: 110,
                                        color: :gray
                                      })
    )

    cancel_button.text(
      LyricsStyle.text_style({
                               data: "Cancel",
                               component: { size: LyricsStyle.dimensions[:text_normal] },
                               color: LyricsStyle.colors[:text_primary],
                               left: 35,
                               top: 5
                             })
    )

    confirm_button.touch(true) do
      prev_left = editor_container.left
      prev_top = editor_container.top
      new_timecode = new_timecode_field.data.to_i
      new_text = new_text_field.data

      if new_timecode > 0 && !new_text.empty?
        lyrics.content[new_timecode] = new_text

        counter = grab(:counter)
        current_position = counter.timer[:position]
        update_lyrics(current_position, lyrics, counter)

        if new_timecode > @length
          @length = new_timecode
        end

        full_refresh_viewer(current_position)
        dialog_container.delete({ recursive: true })
        editor_container.delete({ recursive: true })
        show_lyrics_editor(prev_left, prev_top)
        update_song_listing
      else
        dialog_container.blink(LyricsStyle.colors[:danger])
      end

    end

    cancel_button.touch(true) do
      dialog_container.delete({ recursive: true })
    end
  end
end