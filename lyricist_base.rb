# frozen_string_literal: true

# Classe principale pour gérer l'affichage et l'enregistrement des paroles
class Lyricist < Atome
  attr_accessor :lyrics, :record, :replace_mode, :length, :counter

  def initialize(content = nil)
    @tempo = 120
    @record = false
    @imported_lyrics='none'
    @playing = false
    @replace_mode = false
    @default_length = 1
    @length = @default_length
    @original_number_of_lines = 3
    @number_of_lines = @original_number_of_lines
    @actual_position = 0
    @editor_open = false
    @title="ices from hell"
    @list={}
    @allow_next=true
    # Variable d'instance pour l'anticipation des paroles (en secondes)
    @lyrics_anticipation_time = 0.0
    build_ui
    if content
      new_song(content)
    end
    # create a new audio object
    audio({  id: :song_audio })
  end
  def fullscreen
    lyrics_support=grab(:lyrics_support)
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
  def new_song(content)
    @lyrics=content
    grab(:lyric_viewer).content(content)
    # last_key, last_value = content.to_a.last
    # @default_length = last_key
    # @length = @default_length
    refresh_viewer(0)
  end
end