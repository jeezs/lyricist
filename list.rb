# Ajoutez cette méthode à votre classe Lyricist
class Lyricist

  def build_list_manager
    # Bouton List dans la barre d'outils
    list_button = button({
                           label: :list,
                           id: :list_button,
                           top: LyricsStyle.dimensions[:margin],
                           left: LyricsStyle.positions[:seventh_column],
                           parent: :tool_bar
                         })

    # Créer le panneau de liste (initialement caché)
    grab('main_stage').box({
                             id: :list_panel,
                             width: 400,
                             bottom: 50,
                             top: 0,
                             height: :auto,
                             left: 150,
                             color: LyricsStyle.colors[:background],
                             border: { color: LyricsStyle.colors[:primary], width: 2 },
                             depth: 10,
                             overflow: :auto,
                             display: :none,
                             attach: :lyrics_support
                           })

    # Ajouter une barre de titre au panneau
    list_title_bar = grab('list_title_bar').box({
                                                  id: :list_title_bar,
                                                  width: 400,
                                                  height: 40,
                                                  top: 0,
                                                  left: 0,
                                                  color: LyricsStyle.colors[:primary],
                                                  attach: :list_panel
                                                })
    title_bar_list_text = list_title_bar.text({ id: :list_title,
                                              position: :absolute, top: LyricsStyle.dimensions[:margin] * 3,
                                                left: LyricsStyle.dimensions[:margin] * 3,
                                                data: 'List name', edit: true, color: LyricsStyle.colors[:secondary] })
    @list_title = 'new list'
    title_bar_list_text.keyboard(:down) do |native_event|
      event = Native(native_event)
      if event[:keyCode].to_s == '13' # Touche Entrée
        @list_title = title_bar_list_text.data
        title_bar_list_text.blink(:orange)
        event.preventDefault
      end
    end

    # Ajouter un titre
    grab('main_stage').text({
                              content: "Playlist Manager",
                              id: :list_panel_title,
                              width: 300,
                              height: 30,
                              top: 10,
                              left: 10,
                              size: LyricsStyle.dimensions[:text_medium],
                              color: :white,
                              attach: :list_title_bar
                            })

    # Conteneur pour la liste
    grab('main_stage').box({
                             id: :list_container,
                             width: 380,
                             height: :auto,
                             top: 50,
                             bottom: 0,
                             left: 10,
                             color: LyricsStyle.colors[:background],
                             attach: :list_panel
                           })

    # Bouton pour ajouter une nouvelle chanson
    add_song = button({
                        label: :new,
                        id: :add_song_to_list,
                        top: :auto,
                        bottom: 3,
                        left: 10,
                        parent: :list_panel
                      })

    # Bouton pour sauvegarder les changements
    save_list = button({
                         label: "Save",
                         id: :save_list,
                         top: :auto,
                         bottom: 3,
                         left: :auto,
                         right: 10,
                         parent: :list_panel
                       })

    # Comportement du bouton List
    list_button.touch(true) do
      if grab(:list_panel).display == :none
        grab(:list_panel).display(:block)
        grab(:import_module).display(:none)
        grab(:lyrics_editor_container).delete({ recursive: true }) if grab(:lyrics_editor_container)
        refresh_song_list
      else
        grab(:list_panel).display(:none)
      end
      update_song_listing
    end

    # Comportement du bouton Add Current
    add_song.touch(true) do
      add_current_song_to_list
      refresh_song_list
    end

    # Comportement du bouton Save List
    save_list.touch(true) do
      save_playlist
    end
  end

  ## Méthode pour rafraîchir la liste affichée
  # def refresh_song_list
  #   # Supprimer tous les éléments actuels de la liste
  #   list_container = grab(:list_container)
  #   list_container.clear(true)
  #   # Vérifier si @list existe
  #   # Trier les clés numériquement
  #   sorted_keys = @list.keys.sort_by { |k| k.to_i }
  #
  #   # Position de départ pour les éléments de la liste
  #   top_position = 10
  #
  #   # Créer un élément pour chaque chanson
  #
  #   sorted_keys.each do |key|
  #     item = @list[key]
  #     next unless item && item["title"]
  #
  #     # Créer le conteneur pour l'élément
  #     grab('main_stage').box({
  #                              id: "song_item_#{key}",
  #                              width: 360,
  #                              height: 50,
  #                              top: top_position,
  #                              left: 0,
  #                              smooth: 6,
  #                              color: LyricsStyle.colors[:primary],
  #                              attach: :list_container
  #                            })
  #
  #     # Numéro d'ordre (éditable)
  #     grab('main_stage').text({
  #                                              data: key.to_s,
  #                                              id: "order_#{key}",
  #                                              height: 30,
  #                                              position: :absolute,
  #                                              top: 10,
  #                                              left: 10,
  #                                              edit: true,
  #                                              color: :lightgray,
  #                                              # size: LyricsStyle.dimensions[:text_small],
  #                                              attach: "song_item_#{key}"
  #                                            })
  #
  #     # Titre de la chanson
  #     grab('main_stage').text({
  #                               data: item["title"].to_s,
  #                               id: "title_#{key}",
  #                               width: 200,
  #                               position: :absolute,
  #                               height: 30,
  #                               top: 10,
  #                               left: 50,
  #                               # size: LyricsStyle.dimensions[:text_small],
  #                               color: :lightgray,
  #                               attach: "song_item_#{key}"
  #                             })
  #
  #     # Bouton pour charger cette chanson
  #     load_button = button({
  #                            label: "Load",
  #                            id: "load_#{key}",
  #                            top: 10,
  #                            left: 260,
  #                            width: 40,
  #                            height: 30,
  #                            size: LyricsStyle.dimensions[:text_small],
  #                            # color: LyricsStyle.colors[:primary],
  #                            parent: "song_item_#{key}"
  #                          })
  #
  #     # Bouton pour supprimer cette chanson
  #     delete_button = button({
  #                              label: "X",
  #                              id: "delete_#{key}",
  #                              top: 10,
  #                              left: 310,
  #                              width: 30,
  #                              height: 30,
  #                              size: LyricsStyle.dimensions[:text_small],
  #                              color: LyricsStyle.colors[:danger],
  #                              parent: "song_item_#{key}"
  #                            })
  #
  #     # Action du bouton Load
  #     load_button.touch(true) do
  #       load_song_from_list(key)
  #     end
  #
  #     # Action du bouton Delete
  #     delete_button.touch(true) do
  #       delete_song_from_list(key)
  #       # wait 0.5 do
  #         refresh_song_list
  #       # end
  #     end
  #
  #     # Action sur le changement d'ordre
  #     grab("order_#{key}").keyboard(:down) do |native_event|
  #       event = Native(native_event)
  #       if event[:keyCode].to_s == '13' # Touche Entrée
  #
  #         new_order = grab("order_#{key}").data
  #         alert "here ??? >>>>#{new_order}"
  #         reorder_song(key, new_order)
  #         refresh_song_list
  #         update_song_listing
  #         event.preventDefault
  #       end
  #     end
  #
  #     # Incrémenter la position pour le prochain élément
  #     top_position += 60
  #   end
  # end

  def refresh_song_list
    # Supprimer tous les éléments actuels de la liste
    list_container = grab(:list_container)
    list_container.clear(true)

    # Vérifier si @list existe
    return unless @list && !@list.empty?

    # Capturer une copie locale de @list qui ne sera pas modifiée
    current_list = @list.dup

    # Trier les clés numériquement
    sorted_keys = current_list.keys.sort_by { |k| k.to_i }

    # Position de départ pour les éléments de la liste
    top_position = 10

    # Créer un élément pour chaque chanson
    sorted_keys.each do |key|
      item = current_list[key]
      next unless item && item["title"]

      # Créer le conteneur pour l'élément
      grab('main_stage').box({
                               id: "song_item_#{key}",
                               width: 360,
                               height: 50,
                               top: top_position,
                               left: 0,
                               smooth: 6,
                               color: LyricsStyle.colors[:primary],
                               attach: :list_container
                             })

      # Numéro d'ordre (éditable)
      grab('main_stage').text({
                                data: key.to_s,
                                id: "order_#{key}",
                                height: 30,
                                position: :absolute,
                                top: 10,
                                left: 10,
                                edit: true,
                                color: :lightgray,
                                attach: "song_item_#{key}"
                              })

      # Titre de la chanson
      grab('main_stage').text({
                                data: item["title"].to_s,
                                id: "title_#{key}",
                                width: 200,
                                position: :absolute,
                                height: 30,
                                top: 10,
                                left: 50,
                                color: :lightgray,
                                attach: "song_item_#{key}"
                              })

      # Bouton pour charger cette chanson
      load_button = button({
                             label: "Load",
                             id: "load_#{key}",
                             top: 10,
                             left: 260,
                             width: 40,
                             height: 30,
                             size: LyricsStyle.dimensions[:text_small],
                             parent: "song_item_#{key}"
                           })

      # Bouton pour supprimer cette chanson
      delete_button = button({
                               label: "X",
                               id: "delete_#{key}",
                               top: 10,
                               left: 310,
                               width: 30,
                               height: 30,
                               size: LyricsStyle.dimensions[:text_small],
                               color: LyricsStyle.colors[:danger],
                               parent: "song_item_#{key}"
                             })

      # Action du bouton Load
      load_button.touch(true) do
        # Au lieu d'utiliser la clé directement, chercher l'élément par titre
        title_to_load = item["title"].to_s
        new_key = find_song_key_by_title(title_to_load)
        load_song_from_list(new_key) if new_key
      end

      # Action du bouton Delete
      delete_button.touch(true) do
        # Au lieu d'utiliser la clé directement, chercher l'élément par titre
        title_to_delete = item["title"].to_s
        new_key = find_song_key_by_title(title_to_delete)

        if new_key
          delete_song_from_list(new_key)
          # wait 0.2 do
            refresh_song_list
          # end
        end
      end

      # Action sur le changement d'ordre
      grab("order_#{key}").keyboard(:down) do |native_event|
        event = Native(native_event)
        if event[:keyCode].to_s == '13' # Touche Entrée
          # Au lieu d'utiliser la clé directement, chercher l'élément par titre
          title_to_reorder = item["title"].to_s
          new_key = find_song_key_by_title(title_to_reorder)
          new_order = grab("order_#{key}").data

          if new_key
            reorder_song(new_key, new_order)
            refresh_song_list
            update_song_listing
          end

          event.preventDefault
        end
      end

      # Incrémenter la position pour le prochain élément
      top_position += 60
    end
  end

  # Nouvelle fonction d'aide pour trouver une clé par titre
  def find_song_key_by_title(title)
    return nil unless @list

    @list.each do |key, item|
      return key if item && item["title"].to_s == title
    end

    nil # Retourne nil si aucune correspondance n'est trouvée
  end
  # Méthode pour charger une chanson depuis la liste
  def load_song_from_list(key)
    return unless @list && @list[key]

    song_data = @list[key]

    # # On ferme le panneau
    # grab(:list_panel).display(:none)

    # On arrête la lecture en cours
    stop_audio(@audio_object) if @audio_object
    counter = grab(:counter)
    counter.timer({ stop: true }) if counter
    # On charge la nouvelle chanson
    @title = song_data["title"]
    grab('title_label').data(@title) if grab('title_label')

    # Initialiser l'audio
    init_audio(song_data["song"])

    # Charger les paroles
    lyrics = eval(song_data["lyrics"]) rescue {}
    grab(:lyric_viewer).content(lyrics) if grab(:lyric_viewer)
    raw_text = song_data[:raw]

    grab(:importer_support).clear(true)
    parse_song_lyrics(raw_text)
    @imported_lyrics = raw_text

    # Rafraîchir l'affichage
    full_refresh_viewer(0)

  end

  # Méthode pour supprimer une chanson de la liste
  # def delete_song_from_list(key)
  #   return unless @list && @list[key]
  #
  #   # Supprimer l'élément
  #   @list.delete(key)
  #
  #   # Réorganiser les indices si nécessaire
  #   reorder_all_songs
  # end
  # Remplacer complètement la fonction delete_song_from_list
  def delete_song_from_list(key)
    return unless @list && @list[key]

    # Mémoriser le titre de la chanson avant suppression (pour le log)
    song_title = @list[key]["title"] rescue "inconnu"
    puts "Suppression de la chanson '#{song_title}' (clé: #{key})"

    # Supprimer l'élément
    @list.delete(key)

    # Ne pas appeler reorder_all_songs ici - C'est le changement crucial
    # reorder_all_songs  <-- Ne pas exécuter cette ligne

    puts "Élément supprimé. Nombre d'éléments restants: #{@list.size}"

    # Rafraîchir l'UI pour refléter les changements
    # Mais ne pas le faire ici, car cela sera géré par l'appelant
  end

  # Méthode pour réorganiser une chanson
  def reorder_song(old_key, new_key)
    return unless @list && @list[old_key]
    return if old_key == new_key

    # Sauvegarder les données
    song_data = @list[old_key]

    # Supprimer l'ancienne entrée
    @list.delete(old_key)

    # Ajouter à la nouvelle position
    @list[new_key] = song_data

    # Réorganiser les indices si nécessaire
    reorder_all_songs
  end

  # Méthode pour réorganiser tous les indices
  # def reorder_all_songs
  #   # Créer une copie temporaire triée
  #   sorted_items = @list.to_a.sort_by { |k, _| k.to_i }
  #
  #   # Vider la liste actuelle
  #   @list = {}
  #
  #   # Réinsérer avec des indices consécutifs
  #   sorted_items.each_with_index do |(_, item), index|
  #     @list[(index + 1).to_s] = item
  #   end
  # end
  def reorder_all_songs
    # Créer une copie temporaire triée
    sorted_items = @list.to_a.sort_by { |k, _| k.to_i }

    # Au lieu de vider complètement la liste et de la recréer,
    # nous allons la mettre à jour de manière incrémentale

    # Stocker les anciennes clés dans un ordre qui correspond aux nouvelles
    old_keys = sorted_items.map { |k, _| k }

    # Créer un mappage des anciennes clés vers les nouvelles
    key_mapping = {}

    sorted_items.each_with_index do |(old_key, item), index|
      new_key = (index + 1).to_s
      key_mapping[old_key] = new_key

      # Ne modifie pas l'élément si la clé est déjà correcte
      next if old_key == new_key

      # Mettre à jour l'élément dans @list avec la nouvelle clé
      @list[new_key] = item

      # Supprimer l'ancienne entrée seulement si elle est différente
      @list.delete(old_key) if old_key != new_key
    end

    # Après avoir mis à jour les clés, mettre à jour tous les événements et éléments UI
    # liés à ces clés. Cette étape est nécessaire mais manquante dans ta fonction.
    # Elle devrait être effectuée en rafraîchissant l'interface.

    # Appeler refresh_song_list pour mettre à jour l'UI avec les nouvelles clés
    # wait 0.3 do
      refresh_song_list
    # end
  end

  # Méthode pour ajouter la chanson actuelle à la liste
  def add_current_song_to_list(song_nb = nil)
    return unless @audio_path && @title

    # Récupérer les paroles actuelles
    current_lyrics = grab(:lyric_viewer).content.to_s rescue "{}"

    # Créer une nouvelle entrée
    new_song = {
      "lyrics" => current_lyrics,
      "song" => @audio_path,
      "title" => @title,
      "raw" => @imported_lyrics

    }

    # Déterminer le prochain numéro disponible
    next_key = @list.empty? ? "1" : (@list.keys.map(&:to_i).max + 1).to_s

    # Ajouter à la liste
    if song_nb
      @list[song_nb] = new_song
    else
      @list[next_key] = new_song
    end

  end

  # Méthode pour sauvegarder la playlist
  def save_playlist
    update_song_listing
    content_to_save = @list
    list_tile = "#{@list_title}.prx"
    save_file(list_tile, content_to_save)
  end

  # Pour charger une playlist sauvegardée (à ajouter au bouton load existant)
  def load_playlist(file_content)
    playlist_data = eval(file_content) rescue {}
    if playlist_data.is_a?(Hash) && !playlist_data.empty?
      @list = playlist_data
      refresh_song_list
    end
  end

  # Ajouter cette ligne à la méthode init ou initialize de votre classe
  def initialize_list_manager
    # Initialiser la liste si elle n'existe pas
    build_list_manager # Construire l'interface du gestionnaire de liste
  end

end
