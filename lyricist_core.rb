# frozen_string_literal: true

class Lyricist < Atome
  # Méthodes pour la gestion des paroles
  def closest_values(hash, target, count = 1)
    return [] if hash.empty?
    sorted_keys = hash.keys.sort
    closest_index = sorted_keys.index(sorted_keys.min_by { |key| (key - target).abs })
    return [] if closest_index.nil?
    sorted_keys[closest_index, count].map { |key| hash[key] }.compact
  end

  def closest_key_before(hash, target)
    filtered_keys = hash.keys.select { |key| key <= target }
    filtered_keys.max
  end

  def format_lyrics(lyrics_array, target)
    if target.data != lyrics_array[0] && grab(:counter).content == :play
      target.data(lyrics_array[0])
      lyrics_array.each_with_index do |lyric, index|
        unless index == 0
          child = target.text({ 
            data: lyric, 
            component: { size: LyricsStyle.dimensions[:text_xlarge] } 
          })
          child.edit(false)
          child.width(LyricsStyle.dimensions[:line_width])
          child.color(LyricsStyle.colors[:text_primary])
          child.left(0)
          child.position(:absolute)
          child.top(LyricsStyle.dimensions[:text_xlarge] * index)
        end
      end
    end
  end

  def update_lyrics(value, target, timer_found)
    timer_found.data(value)
    timer_found.timer[:position] = value
    timer_found.timer[:start] = value
    @actual_position = value
    current_lyrics = closest_values(target.content, value, @number_of_lines)
    format_lyrics(current_lyrics, target)
  end

  def alter_lyric_event(lyrics)
    lyrics = grab(:lyric_viewer)
    counter = grab(:counter)
    current_position = counter.timer[:position]
    lyrics.content[current_position] = lyrics.data
    lyrics.blink(LyricsStyle.colors[:danger])
  end

  def full_refresh_viewer(at = 0)
    grab(:timeline_slider).delete({ force: true })
    build_timeline_slider
    grab(:timeline_slider).value(0)

    grab(:timeline_slider).delete({ force: true })
    build_timeline_slider
    grab(:timeline_slider).value(@length)

    grab(:timeline_slider).delete({ force: true })
    build_timeline_slider
    grab(:timeline_slider).value(at)
  end

  def refresh_viewer(at = 0)
    # TODO: optimise and find a better way to refresh the viewer
    # removing the two lines below is not a good way to do it, and efficient
    grab(:timeline_slider).delete({ force: true })
    build_timeline_slider
    grab(:timeline_slider).value(at)
  end

  def clear_all
    lyric_viewer = grab(:lyric_viewer)
    lyric_viewer.content = {}
    @length = @default_length
    lyric_viewer.clear(true)
    lyric_viewer.data('')
    grab(:timeline_slider).delete({ force: true })
    build_timeline_slider
  end

  # Analyse et affichage des paroles de chanson

end