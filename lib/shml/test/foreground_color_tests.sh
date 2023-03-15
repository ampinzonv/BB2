source ./shml.sh

function run_tests {
  # Foreground - color
  ##
  assert_equal "$(fgcolor black 'foo')" \
          "$(echo -e '\033[30mfoo\033[39m')" \
          "black foreground color"

  assert_equal "$(fgcolor red 'foo')" \
          "$(echo -e '\033[31mfoo\033[39m')" \
          "red foreground color"

  assert_equal "$(fgcolor green 'foo')" \
          "$(echo -e '\033[32mfoo\033[39m')" \
          "green foreground color"

  assert_equal "$(fgcolor yellow 'foo')" \
          "$(echo -e '\033[33mfoo\033[39m')" \
          "yellow foreground color"

  assert_equal "$(fgcolor blue 'foo')" \
          "$(echo -e '\033[34mfoo\033[39m')" \
          "blue foreground color"

  assert_equal "$(fgcolor magenta 'foo')" \
          "$(echo -e '\033[35mfoo\033[39m')" \
          "magenta foreground color"

  assert_equal "$(fgcolor cyan 'foo')" \
          "$(echo -e '\033[36mfoo\033[39m')" \
          "cyan foreground color"

  assert_equal "$(fgcolor gray 'foo')" \
          "$(echo -e '\033[90mfoo\033[39m')" \
          "gray foreground color"

  assert_equal "$(fgcolor darkgray 'foo')" \
          "$(echo -e '\033[91mfoo\033[39m')" \
          "darkgray foreground color"

  assert_equal "$(fgcolor lightgreen 'foo')" \
          "$(echo -e '\033[92mfoo\033[39m')" \
          "lightgreen foreground color"

  assert_equal "$(fgcolor lightyellow 'foo')" \
          "$(echo -e '\033[93mfoo\033[39m')" \
          "lightyellow foreground color"

  assert_equal "$(fgcolor lightblue 'foo')" \
          "$(echo -e '\033[94mfoo\033[39m')" \
          "lightblue foreground color"

  assert_equal "$(fgcolor lightmagenta 'foo')" \
          "$(echo -e '\033[95mfoo\033[39m')" \
          "lightmagenta foreground color"

  assert_equal "$(fgcolor lightcyan 'foo')" \
          "$(echo -e '\033[96mfoo\033[39m')" \
          "lightcyan foreground color"

  assert_equal "$(fgcolor white 'foo')" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          "white foreground color"

  # Terminators
  assert_equal "$(fgcolor white)foo$(fgcolor)" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          'color foreground and end color'

  assert_equal "$(fgcolor white)foo$(fgcolor end)" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          'color foreground and end color'

  assert_equal "$(fgcolor white)foo$(fgcolor off)" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          'color foreground and end color'

  assert_equal "$(fgcolor white)foo$(fgcolor reset)" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          'color foreground and end color'

  # Aliases
  assert_equal "$(c white 'foo')" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          "'c' alias works work"

  assert_equal "$(color white 'foo')" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          "'color' alias works'"

  assert_equal "$(fgc white 'foo')" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          "'fgc' alias works'"

  # Midex aliases
  assert_equal "$(fgcolor white)foo$(color)" \
          "$(echo -e '\033[97mfoo\033[39m')" \
          'color foreground and end color'

  # Misc
  assert_equal "$(fgcolor 'white' 'foo bar')" \
          "$(echo -e '\033[97mfoo bar\033[39m')" \
          "single quotes and spaces work"

  assert_equal "$(fgcolor "white" 'foo bar')" \
          "$(echo -e '\033[97mfoo bar\033[39m')" \
          "double quotes and spaces work"
}
