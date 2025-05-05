# frozen_string_literal: true

class Lyricist < Atome
  # Méthodes pour la gestion des paroles

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

    # Ne pas modifier la cible
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


  def update_lyrics(value, target)
    lyrics_array = closest_values(target.content, value, @number_of_lines)
    return if lyrics_array.empty?

    # On vérifie si on doit mettre à jour l'affichage
    if target.data != lyrics_array[0] && grab(:counter).content == :play
      # Mise à jour de la première ligne
      target.data(lyrics_array[0])

      if lyrics_array[0] == '-end-'
        if @playing
          @allow_next = true
          lyrics_array = []
          target.content = ''
          stop_lyrics
        else
          @allow_next = false
        end
      end

      # Propriétés de style pour la première ligne
      style_first_line = {
        color: LyricsStyle.colors[:first_line_color],
        left: LyricsStyle.positions[:lyrics_left_offset],
        top: LyricsStyle.positions[:lyrics_top_offset],
        component: { size: LyricsStyle.dimensions[:lyrics_size] }
      }

      # Application du style
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
                       LyricsStyle.dimensions[:lyrics_size] *3

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

  # Helper pour la reconstruction du slider
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
    @lyrics = { 0 => "new" }
    lyric_viewer = grab(:lyric_viewer)

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
    rebuild_timeline_slider
  end

  # Nettoyage du cache si nécessaire
  def cleanup_cache
    @sorted_keys_cache = {}
  end

  # Pour réinitialiser l'état du système en cas de besoin
  def reset_lyrics_system
    cleanup_cache
    @actual_position = 0

    # Si lecture en cours, arrêter et redémarrer
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

    save_js.call(filename, content, mime_type)
  end

  # Méthode utilitaire pour inspecter le contenu des paroles
  def inspect_lyrics_content
    lyric_viewer = grab(:lyric_viewer)
    content = lyric_viewer.content

    if content && content.keys.size > 0
      sorted_keys = content.keys.sort
      puts "=== CONTENU DES PAROLES ==="
      puts "Nombre de timecodes: #{sorted_keys.size}"
      puts "Premier timecode: #{sorted_keys.first}"
      puts "Dernier timecode: #{sorted_keys.last}"

      # Afficher les 5 premiers timecodes et leur contenu
      puts "Premiers timecodes:"
      sorted_keys[0..4].each do |key|
        puts "  #{key}: #{content[key]}"
      end

      # Afficher les 5 derniers timecodes et leur contenu
      puts "Derniers timecodes:"
      sorted_keys[-5..-1].each do |key|
        puts "  #{key}: #{content[key]}"
      end
      puts "==========================="
    else
      puts "Aucun contenu de paroles disponible"
    end
  end
end