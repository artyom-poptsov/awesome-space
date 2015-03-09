--[==[
spaceapi.lua -- Show a hackerspace status.

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

local setmetatable = setmetatable

local vicious = require("vicious")
local naughty = require("naughty")
local spaceapi = require("awesome_space.spaceapi")
local awful = require("awful")
local mouse =  mouse
local pairs = pairs
local naughty = { notify = naughty.notify, destroy = naughty.destroy  }
local util = awful.util
local tooltip = awful.tooltip
local menu = awful.menu
local prompt = awful.prompt

module ("awesome_space.widget")

local directory = nil

-- Space API endpoint to be observed to
local endpoint = false;

-- Cached hackerspace data
local hackerspace = nil

local popup = nil

local widget_menu = nil;


-- Set hackerspace to NAME.
function set_hackerspace_x (name)
   directory = spaceapi.get_spaceapi_directory ()
   endpoint = {
      name      = name,
      cache_url = directory[name]
   }
end

-- Get hackerspace state from the given data HACKERSPACE_DATA.
local function get_state (hackerspace_data)
   local state_open = hackerspace_data.state.open
   if state_open == true then
      return "open"
   elseif state_open == false then
      return "closed"
   else
      return "undefined"
   end
end

-- Update hackerspace data
function update ()
   hackerspace = spaceapi.get_hackerspace_data (endpoint.cache_url)
end


local indicator = {
   ["open"]      = "<span color='#7fff00'>⬤</span>",
   ["closed"]    = "<span color='#ffff00'>⬤</span>",
   ["undefined"] = "<span color='#bebebe'>⬤</span>"
}

function default_formatter (widget, args)
   return indicator[args["state"]]
end


-- Taken from <http://lua-users.org/wiki/StringRecipes>
local function wrap (str, limit, indent, indent1)
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

local function make_list (elements)
   local result = ''
   for idx,val in pairs (elements) do
      if val then
         result = result .. '■ ' .. val .. '\n'
      end
   end
   return result
end


function show_popup ()
   if hackerspace ~= nil then
      local state = get_state (hackerspace)
      local location_pos
         = hackerspace.location.lon .. ', ' .. hackerspace.location.lat

      local notify_text = hackerspace.url .. '\n\n'
         .. '<u>Status</u>\n' .. indicator[state] .. ' ' .. state .. '\n'
         .. '\n'
         .. '<u>Location</u>\n'
         .. make_list ({wrap (hackerspace.location.address), location_pos})
         .. '\n'

      local contacts = make_list (hackerspace.contact)
      if contacts ~= '' then
         notify_text = notify_text .. '<u>Contact</u>\n' .. contacts
      end

      popup = naughty.notify ({
                                 title  = hackerspace.space,
                                 text   = notify_text,
                                 timeout = 0,
                                 screen = mouse.screen
                              })
   end
end

function hide_popup ()
   if popup ~= nil then
      naughty.destroy (popup)
   end
   popup = nil
end

function register (widget)
   local widget_t = tooltip ({
                                objects = { widget },
                                timer_function = function ()
                                   if hackerspace ~= nil then
                                      local name = hackerspace.space
                                      local state = get_state (hackerspace)
                                      return name .. ': ' .. state
                                   end
                                end
                             })

   local make_dir_menu = function ()
      local items = {}

      for i,k in pairs (directory) do
         items[#items + 1] = {
            i,
            function ()
               set_hackerspace_x (i)
               update ()
            end
         }
      end

      return items
   end

   local widget_m = nil

   local show_menu = function ()
      if not widget_m then
         widget_m
            = menu ({items = {
                        { "Choose an hackerspace...", make_dir_menu () }
            }})
      end

      widget_m:toggle()
   end

   widget:buttons (util.table.join (
                     awful.button ({ }, 1,
                                  function ()
                                     if popup == nil then
                                        show_popup ()
                                     else
                                        hide_popup ()
                                     end
                                  end),
                     awful.button ({ }, 3, show_menu)))
end


function worker (format, warg)
   if not hackerspace then
      set_hackerspace_x (warg)
   end

   update ()
   return { name = hackerspace.space, state = get_state (hackerspace) }
end


setmetatable(_M, { __call = function(_, ...) return worker(...) end })

-- spaceapi.lua ends here
