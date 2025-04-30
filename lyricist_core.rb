# frozen_string_literal: true

class Lyricist < Atome
  # Méthodes pour la gestion des paroles

  # Variable d'instance pour l'anticipation des paroles (en secondes)
  @lyrics_anticipation_time = 0.0

  def closest_values(hash, target, count = 1)
    return [] if hash.empty?

    # On ajuste la cible en fonction de l'anticipation configurée
    adjusted_target = target - (@lyrics_anticipation_time || 0.0)

    # Utilisation d'une cache pour les clés triées si le hash est grand
    # (optimisation pour éviter de trier à chaque appel)
    @sorted_keys_cache ||= {}
    sorted_keys = @sorted_keys_cache[hash.object_id]

    if sorted_keys.nil? || @sorted_keys_cache_size != hash.size
      sorted_keys = hash.keys.sort
      @sorted_keys_cache[hash.object_id] = sorted_keys
      @sorted_keys_cache_size = hash.size
    end

    # On utilise une recherche binaire pour les grands ensembles de données
    if sorted_keys.size > 50
      low, high = 0, sorted_keys.size - 1
      closest_index = nil

      # Recherche binaire optimisée
      while low <= high
        mid = (low + high) / 2
        if sorted_keys[mid] < adjusted_target
          low = mid + 1
        elsif sorted_keys[mid] > adjusted_target
          high = mid - 1
        else
          # Correspondance exacte trouvée
          closest_index = mid
          break
        end
      end

      # Si on n'a pas trouvé de correspondance exacte, on prend la plus proche
      if closest_index.nil?
        # Gérer les cas limites
        if low >= sorted_keys.size
          closest_index = sorted_keys.size - 1
        elsif low <= 0
          closest_index = 0
        else
          # Comparer les deux valeurs les plus proches
          prev = sorted_keys[low - 1]
          current = sorted_keys[low]
          closest_index = (adjusted_target - prev).abs < (current - adjusted_target).abs ? low - 1 : low
        end
      end
    else
      # Pour les petits ensembles, on utilise la méthode originale
      closest_index = sorted_keys.index(sorted_keys.min_by { |key| (key - adjusted_target).abs })
    end

    return [] if closest_index.nil?

    # On limite l'index à la taille de la liste
    closest_index = [closest_index, sorted_keys.size - 1].min

    # Extraction des valeurs correspondantes
    result = []
    count.times do |i|
      index = closest_index + i
      break if index >= sorted_keys.size

      key = sorted_keys[index]
      result << hash[key] if hash[key]
    end

    result
  end

  def closest_key_before(hash, target)
    return nil if hash.empty?

    # Recherche optimisée de la clé la plus proche avant target
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
    nil # Retourne nil si aucune correspondance n'est trouvée
  end

  def format_lyrics(lyrics_array, target)

    return if lyrics_array.empty?

    # On vérifie si on doit mettre à jour l'affichage

    if target.data != lyrics_array[0] && grab(:counter).content == :play
      # Mise à jour de la première ligne
      target.data(lyrics_array[0])
      if lyrics_array[0] == '<end>'
        lyrics_array = []
        target.content = ''
        stop_lyrics
      end

      # Propriétés de style pour la première ligne
      style_first_line = {
        color: LyricsStyle.colors[:first_line_color],
        left: LyricsStyle.positions[:lyrics_left_offset],
        top: LyricsStyle.positions[:lyrics_top_offset],
        component: { size: LyricsStyle.dimensions[:lyrics_size] }
      }

      # Application du style en une seule opération (si possible)
      if target.respond_to?(:update)
        target.update(style_first_line)
      else
        style_first_line.each { |prop, val| target.send(prop, val) }
      end

      # Style commun pour les lignes suivantes
      common_style = {
        edit: false,
        width: LyricsStyle.dimensions[:lyrics_width],
        color: LyricsStyle.colors[:other_lines_color],
        position: :absolute
      }

      # Création des lignes suivantes
      lyrics_array.each_with_index do |lyric, index|
        next if index == 0

        top_position = LyricsStyle.dimensions[:next_Line_lyrics_size] * index +
                       LyricsStyle.dimensions[:lyrics_size] / 3

        # Paramètres pour la ligne
        child_params = {
          data: lyric,
          component: { size: LyricsStyle.dimensions[:next_Line_lyrics_size] },
          top: top_position * LyricsStyle.dimensions[:percent_offset_between_lines]
        }.merge(common_style)

        # Création du texte enfant
        target.text(child_params)

      end
    end
  end

  def update_lyrics(value, target, timer_found)
    # Mise à jour du timer en une seule opération si possible
    if timer_found.respond_to?(:update)
      timer_found.update({
                           data: value,
                           timer: { position: value, start: value }
                         })
    else
      timer_found.data(value)
      timer_found.timer[:position] = value
      timer_found.timer[:start] = value
    end

    @actual_position = value

    # Récupération et formatage des paroles
    current_lyrics = closest_values(target.content, value, @number_of_lines)
    format_lyrics(current_lyrics, target)
  end

  # Helper pour la reconstruction du slider
  def rebuild_timeline_slider(at = 0)
    slider = grab(:timeline_slider)
    slider.delete({ force: true }) if slider
    build_timeline_slider
    grab(:timeline_slider).value(at)
  end

  def full_refresh_viewer(at = 0)
    # Reconstruction optimisée
    rebuild_timeline_slider(0)
    rebuild_timeline_slider(@length)
    rebuild_timeline_slider(at)
  end

  def refresh_viewer(at = 0)
    # Utilisation de la méthode helper
    rebuild_timeline_slider(at)
  end

  def clear_all

    @lyrics = { 0 => "new" }
    lyric_viewer = grab(:lyric_viewer)

    # Regroupement des opérations
    if lyric_viewer.respond_to?(:update)
      lyric_viewer.update({
                            content: {},
                            data: ''
                          })
    else
      lyric_viewer.content = @lyrics
      lyric_viewer.data('')
    end

    @length = @default_length

    lyric_viewer.clear(true)

    # Reconstruction du slider
    rebuild_timeline_slider

  end

  # Méthode pour définir l'anticipation des paroles (en secondes)
  def set_lyrics_anticipation(seconds)
    @lyrics_anticipation_time = seconds.to_f
    # Vider le cache des clés triées quand l'anticipation change
    @sorted_keys_cache = {}
  end

  # Méthode pour récupérer la valeur actuelle d'anticipation
  def get_lyrics_anticipation
    @lyrics_anticipation_time || 0.0
  end

  # Nettoyage du cache si nécessaire
  def cleanup_cache
    @sorted_keys_cache = {}
  end

  def save_file(filename, content, mime_type = 'text/plain')
    # Créer une fonction JavaScript avec des noms de paramètres explicites
    save_js = JS.eval(<<~JS)
      (function(fileName, fileContent, mimeType) {
        console.log("Saving file:", fileName, "with content:", fileContent);
        
        // Créer le Blob avec le contenu
        var blob = new Blob([fileContent], {type: mimeType});
        
        // Créer l'URL
        var url = URL.createObjectURL(blob);
        
        // Créer le lien de téléchargement avec le nom de fichier correct
        var link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', fileName);  // Utiliser setAttribute pour plus de fiabilité
        
        // Assurer la visibilité du lien
        link.style.display = 'none';
        
        // Ajouter au DOM, cliquer et supprimer
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        // Libérer l'URL
        setTimeout(function() {
          URL.revokeObjectURL(url);
        }, 100);
        
        return true;
      })
    JS

    # Appeler la fonction avec les arguments dans le bon ordre
    save_js.call(filename, content, mime_type)
  end
end