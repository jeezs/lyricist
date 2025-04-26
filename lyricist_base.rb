# frozen_string_literal: true

# Classe principale pour gérer l'affichage et l'enregistrement des paroles
class Lyricist < Atome
  attr_accessor :lyrics, :record, :replace_mode, :length, :counter

  def initialize(content = nil)
    @tempo = 120
    @record = false
    @playing = false
    @replace_mode = false
    @default_length = 1
    @length = @default_length
    @original_number_of_lines = 4
    @number_of_lines = @original_number_of_lines
    @actual_position = 0
    @editor_open = false
    @title="ices from hell"
    build_ui
    if content
      new_song(content)
    end
    # create a new audio object
    audio({  id: :song_audio })
  end

  def new_song(content)
    grab(:lyric_viewer).content(content)
    last_key, last_value = content.to_a.last
    @default_length = last_key
    @length = @default_length
    refresh_viewer(0)
  end
end