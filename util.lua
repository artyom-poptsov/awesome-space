--[==[
util.lua -- Handy utilites for Awesome Space widget.

Copyright (C) 2015  Artyom V. Poptsov <poptsov.artyom@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]==]

module ("awesome_space.util")

-- Taken from <http://lua-users.org/wiki/StringRecipes>
function wrap (str, limit, indent, indent1)
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 72
  local here = 1 - #indent1
  return indent1 .. str:gsub ("(%s+)()(%S+)()",
                              function (sp, st, word, fi)
                                 if (fi - here) > limit then
                                    here = st - #indent
                                    return "<br>" .. indent .. word
                                 end
                              end)
end

-- Search through an associative table for the KEY, return the found
-- element or nil if no element found.
function assoc (t, key)
   local result = nil
   for i = 1, #t do
      if t[i][1] == key then
         result = t[i]
         break
      end
   end
   return result
end

--- util.lua ends here.
