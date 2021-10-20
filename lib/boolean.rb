# frozen_string_literal: true

# Original code taken from https://github.com/rails/rails/blob/6-1-stable/activemodel/lib/active_model/type/boolean.rb

# Copyright (c) 2005-2021 David Heinemeier Hansson

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# A class that behaves like a boolean type, including rules for coercion of user input.
#
# === Coercion
# - "false", "f" , "0", +0+ or any other value in +FALSE_VALUES+ will be coerced to +false+
# - Empty strings are coerced to +nil+
# - All other values will be coerced to +true+
class Boolean
  # rubocop:disable Lint/BooleanSymbol
  FALSE_VALUES = [
    false, 0,
    '0', :'0',
    'f', :f,
    'F', :F,
    'false', :false,
    'FALSE', :FALSE,
    'off', :off,
    'OFF', :OFF,
    '', nil
  ].to_set.freeze
  # rubocop:enable Lint/BooleanSymbol

  def cast(value)
    !FALSE_VALUES.include?(value)
  end
end
