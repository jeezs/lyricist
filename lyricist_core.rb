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
      target.color(LyricsStyle.colors[:first_line_color])
      target.left(LyricsStyle.positions[:lyrics_left_offset])
      target.top(LyricsStyle.positions[:lyrics_top_offset])
      # target is the first line in the lyrics viewer
      target.component({ size: LyricsStyle.dimensions[:lyrics_size] })
      lyrics_array.each_with_index do |lyric, index|
        unless index == 0
          child = target.text({
                                data: lyric,

                                component: { size: LyricsStyle.dimensions[:next_Line_lyrics_size] }
                              })
          # child is the other lines in the lyrics viewer
          child.edit(false)
          child.width(LyricsStyle.dimensions[:lyrics_width])
          # child.color(LyricsStyle.colors[:text_primary])
          child.color(  LyricsStyle.colors[:other_lines_color])
          child.position(:absolute)
          child.top(LyricsStyle.dimensions[:next_Line_lyrics_size] * index+LyricsStyle.dimensions[:lyrics_size]/3)
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