# frozen_string_literal: true
require_relative 'lyrics_style'
require_relative 'lyricist_base'
require_relative 'lyricist_ui'
require_relative 'lyricist_buttons'
require_relative 'lyricist_editor'
require_relative 'lyricist_core'

# Création de l'instance et lancement de l'application
lyr = Lyricist.new
lyr.new_song({ 0 => "hello", 594 => "world", 838 => "of", 1295 => "hope" })

open_filer = text({ data: :importimportimportimportimportimportimport, top: 120, left: 120, color: :yellowgreen })
open_filer.import(true) do |val|
  parse_song_lyrics(val)
end
importer do |val|
  parse_song_lyrics(val[:content])
end