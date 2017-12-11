#!/usr/bin/ruby

# Miscellaneous text-based functions to use and stuff...
module TextUtils
  # Takes text, and randomly changes the case of it
  # Stolen from https://stackoverflow.com/a/22657882/1566371
  def random_case(text)
    text.gsub(/./) do |s|
      s.send(%i[upcase downcase].sample)
    end
  end
end
