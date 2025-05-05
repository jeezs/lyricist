# frozen_string_literal: true

class LyricsStyle
  def self.colors
    {
      first_line_color: { red: 0.93, green: 0.93, blue: 0.93 },
      other_lines_color: { red: 0.7, green: 0.7, blue: 0.7 },

      primary: { red: 0.15, green: 0.15, blue: 0.15 },
      secondary: { red: 0.72, green: 0.52, blue: 0.52 },
      third: { red: 0.32, green: 0.32, blue: 0.32 },
      accent: { red: 0.9, green: 0.3, blue: 0.6 },
      danger: { red: 1, green: 0, blue: 0, alpha: 0.3 },
      success: { red: 0.3, green: 0.3, blue: 0.3 },
      warning: { red: 0.95, green: 0.7, blue: 0.2 },
      info: { red: 0.3, green: 0.7, blue: 0.95 },
      background: { red: 0.3, green: 0.3, blue: 0.3 },

      record: { red: 0.9, green: 0.3, blue: 0.6, alpha: 0.8 },
      text_primary: { red: 0.95, green: 0.95, blue: 0.95 },
      text_secondary: { red: 0.7, green: 0.7, blue: 0.85 },
      text_accent: { red: 0.95, green: 0.5, blue: 0.8 },

      container_bg: { red: 0.12, green: 0.12, blue: 0.12, alpha: 1 },
      container_dark: { red: 0.1, green: 0.1, blue: 0.1, alpha: 0.95 },
      container_medium: { red: 0.18, green: 0.18, blue: 0.18, alpha: 0.9 },
      container_light: { red: 0.22, green: 0.22, blue: 0.3, alpha: 0.85 }
    }
  end

  def self.dimensions
    {
      percent_offset_between_lines: 1.3,
      slider_width: 300,

      standard_width: 55,
      medium_width: 80,
      large_width: 140,
      container_width: 600,
      lyrics_width: 669,

      button_height: 25,
      medium_height: 40,
      large_height: 52,
      container_height: 500,
      tool_bar_height: 50,
      slider_height: 25,
      margin: 3,

      text_small: 12,
      text_medium: 14,
      text_normal: 16,
      text_large: 20,
      text_xlarge: 36,
      lyrics_size: 33,
      next_Line_lyrics_size: 30
    }
  end

  def self.decorations
    {
      standard_smooth: 10,
      button_smooth: 9,
      container_smooth: 16,
      standard_shadow: { blur: 15, alpha: 0.7 },
      container_shadow: { blur: 20, alpha: 0.6 },
      button_shadow: { blur: 8, alpha: 0.5 },
      invert_shadow: {
        left: 3,
        top: 3,
        blur: 12,
        invert: true,
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.5
      },
      glow: {
        blur: 18,
        alpha: 0.6,
        red: 0.9,
        green: 0.3,
        blue: 0.6
      }
    }
  end

  # Positions
  def self.positions
    {
      next: 375,
      prev: 345,
      lyrics_left_offset: 39,
      lyrics_top_offset: 25,
      slider_bottom: 25,
      counter_left: 373,

      first_row: 10,
      second_row: 10,
      third_row: 60,
      fourth_row: 110,

      first_column: 10,
      second_column: 63,
      third_column: 124,
      fourth_column: 188,
      fifth_column: 270,
      sixth_column: 405,
      seventh_column: 480,

      timeline_top: :auto,
      editor_default_left: 300,
      editor_default_top: 150
    }
  end

  def self.button_style(options = {})
    style = {
      width: dimensions[:standard_width],
      height: dimensions[:button_height],
      color: colors[:primary],
      smooth: decorations[:button_smooth],
      shadow: decorations[:button_shadow]
    }
    style.merge(options)
  end

  def self.text_style(options = {})
    style = {
      component: { size: dimensions[:text_medium] },
      color: colors[:text_primary],
      position: :absolute
    }
    style.merge(options)
  end

  def self.container_style(options = {})
    style = {
      width: dimensions[:container_width],
      height: dimensions[:container_height],
      smooth: decorations[:container_smooth],
      shadow: decorations[:container_shadow],
    }
    style.merge(options)
  end

  def self.slider_style(options = {})
    style = {
      range: { color: colors[:accent] },
      min: 0,
      width: 399,
      height: dimensions[:medium_height],
      color: colors[:secondary],
      position: :absolute,
      bottom: 20,
      left: 0,
      shadow: decorations[:standard_shadow],
      cursor: {
        color: colors[:accent],
        width: dimensions[:medium_height] + 10,
        height: dimensions[:medium_height] + 10,
        smooth: decorations[:button_smooth],
        shadow: decorations[:glow]
      }
    }
    style.merge(options)
  end

  def self.line_container_style(options = {})
    style = {
      width: 520,
      height: 60,
      left: 15,
      color: colors[:container_medium],
      smooth: decorations[:standard_smooth],
      shadow: decorations[:standard_shadow],
    }
    style.merge(options)
  end

  def self.action_button_style(options = {})
    button_style({
                   width: dimensions[:medium_width],
                   height: dimensions[:medium_height],
                   shadow: decorations[:button_shadow],
                   smooth: decorations[:button_smooth]
                 }.merge(options))
  end

  def self.build_button(parent, options = {})
    default_options = {
      color: colors[:primary],
      width: dimensions[:standard_width],
      height: dimensions[:button_height],
      top: 0,
      left: 0,
      smooth: decorations[:button_smooth],
      shadow: decorations[:button_shadow],
      label: '',
      label_color: colors[:text_primary],
      id: identity_generator
    }

    opts = default_options.merge(options)

    button = parent.box({
                          id: opts[:id],
                          width: opts[:width],
                          height: opts[:height],
                          top: opts[:top],
                          left: opts[:left],
                          color: opts[:color],
                          smooth: opts[:smooth],
                        })

    button.shadow(opts[:shadow]) if opts[:shadow]

    if opts[:label] && !opts[:label].empty?
      button.text({
                    data: opts[:label],
                    component: { size: dimensions[:text_medium] },
                    color: opts[:label_color],
                    position: :absolute,
                    top: opts[:height] / 2 - dimensions[:text_medium] / 2,
                    left: opts[:width] / 2 - dimensions[:text_medium] * 1.5
                  })
    end

    button
  end
end