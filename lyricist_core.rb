# frozen_string_literal: true

class Lyricist < Atome

  def closest_values(hash, target, count = 1)
    return [] if hash.empty?

    # Trier les clés (timecodes)
    sorted_keys = hash.keys.sort

    # Trouver la clé la plus proche qui est inférieure ou égale à la cible
    found_key = nil
    sorted_keys.reverse_each do |key|
      if key <= target
        found_key = key
        break
      end
    end

    # Si aucune clé n'est trouvée (toutes sont supérieures), prendre la première
    if found_key.nil?
      found_key = sorted_keys.first
    end

    # Récupérer le résultat
    result = []
    if found_key
      result << hash[found_key]

      # Ajouter les lignes suivantes si demandé
      if count > 1
        current_index = sorted_keys.index(found_key)
        (1...count).each do |i|
          next_index = current_index + i
          break if next_index >= sorted_keys.size
          next_key = sorted_keys[next_index]
          result << hash[next_key] if hash[next_key]
        end
      end
    end

    result
  end

  def closest_key_before(hash, target)
    return nil if hash.empty?

    max_key = nil
    hash.keys.each do |key|
      max_key = key if key <= target && (max_key.nil? || key > max_key)
    end
    max_key
  end

  def find_key_by_title(hash, title)
    hash.each do |key, value|
      return key if value["title"] == title
    end
    nil
  end

  def prepare_lyrics_display

    lyrics_support = grab(:lyrics_support)

    lyrics_support.text({
                          left: 3,
                          width: LyricsStyle.dimensions[:line_width],
                          data: '',
                          id: :main_line,
                          top: 39,
                          edit: false,
                          component: { size: LyricsStyle.dimensions[:text_xlarge] },
                          position: :absolute,
                          content: { 0 => '' },
                          context: :insert
                        })


    common_style = {
      edit: false,
      width: LyricsStyle.dimensions[:lyrics_width],
      color: LyricsStyle.colors[:other_lines_color],
      position: :absolute
    }

    (1...@number_of_lines).each do |index|
      top_position = LyricsStyle.dimensions[:next_Line_lyrics_size] * index +
                     LyricsStyle.dimensions[:lyrics_size] * 3

      lyrics_support.text({
                            id: :"my_line_#{index}",
                            data: 'next lines',
                            component: { size: LyricsStyle.dimensions[:next_Line_lyrics_size] },
                            top: top_position * LyricsStyle.dimensions[:percent_offset_between_lines]
                          }.merge(common_style))
    end

    setup_lyrics_events

  end

  def alter_lyric_event


    lyrics = grab(:main_line)
    lyrics.color(LyricsStyle.colors[:danger])
    wait 1 do
      lyrics.color(LyricsStyle.colors[:first_line_color])
    end
    lyrics.content[@actual_position] = lyrics.data

  end

  def update_lyrics(value, target)
    lyrics_array = closest_values(target.content, value, @number_of_lines)
    return if lyrics_array.empty?
    return if target.data == lyrics_array[0] || grab(:counter).content != :play

    target.data(lyrics_array[0])

    if lyrics_array[0] == '-end-'
      if @playing
        @allow_next = true
        target.content = ''
        stop_lyrics
      else
        @allow_next = false
      end
      return
    end

    lyrics_array.each_with_index do |lyric, index|
      next if index == 0
      if index < @number_of_lines
        grab(:"my_line_#{index}").data(lyric)
      end
    end
  end

  def rebuild_timeline_slider(at = 0)
    slider = grab(:timeline_slider)
    slider.delete({ force: true }) if slider
    build_timeline_slider
    grab(:timeline_slider).value(at)
  end

  def full_refresh_viewer(at = 0)
    rebuild_timeline_slider(0)
    rebuild_timeline_slider(@length)
    rebuild_timeline_slider(at)
  end

  def refresh_viewer(at = 0)
    rebuild_timeline_slider(at)
  end

  def clear_all
    @lyrics = { 0 => "    " }
    lyric_viewer = grab(:main_line)

    if lyric_viewer.respond_to?(:update)
      lyric_viewer.update({
                            content: {},
                            data: ''
                          })
    else
      lyric_viewer.content = @lyrics
      lyric_viewer.data('')
    end
    (1...@number_of_lines).each do |index|

      grab("my_line_#{index}").data('') if grab("my_line_#{index}")
    end

    @length = @default_length
    rebuild_timeline_slider
  end

  def cleanup_cache
    @sorted_keys_cache = {}
  end

  def reset_lyrics_system
    cleanup_cache
    @actual_position = 0

    if @playing
      stop_lyrics
      wait 0.5 do
        play_lyrics
      end
    end
  end

  def save_file(filename, content, mime_type = 'text/plain')
    save_js = JS.eval(<<~JS)
      (function(fileName, fileContent, mimeType) {
        console.log("Saving file:", fileName, "with content:", fileContent);
        var blob = new Blob([fileContent], {type: mimeType});
        var url = URL.createObjectURL(blob);
        var link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', fileName);  // Utiliser setAttribute pour plus de fiabilité
        link.style.display = 'none';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        setTimeout(function() {
          URL.revokeObjectURL(url);
        }, 100);
        return true;
      })
    JS

    save_js.call(filename, content, mime_type)
  end

  def inspect_lyrics_content
    lyric_viewer = grab(:main_line)
    content = lyric_viewer.content

    if content && content.keys.size > 0
      sorted_keys = content.keys.sort
      sorted_keys[0..4].each do |key|
        puts "  #{key}: #{content[key]}"
      end

      sorted_keys[-5..-1].each do |key|
        puts "  #{key}: #{content[key]}"
      end
    end
  end
end