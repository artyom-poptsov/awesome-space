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
local mouse =  mouse
local naughty = { notify = naughty.notify }

module ("awesome_space.widget")

-- Space API endpoint to be observed to
local endpoint = false;

-- Cached hackerspace data
local hackerspace = nil

local popup = nil


-- Set hackerspace to NAME.
function set_hackerspace_x (name)
   local directory = spaceapi.get_spaceapi_directory ()
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


local indicator = {
   ["open"]      = "<span color='#7fff00'>⬤</span>",
   ["closed"]    = "<span color='#ffff00'>⬤</span>",
   ["undefined"] = "<span color='#bebebe'>⬤</span>"
}

function default_formatter (widget, args)
   return indicator[args["state"]]
end


function on_mouse_enter ()
   if hackerspace ~= nil then
      local state = get_state (hackerspace)
      local notify_text
         = hackerspace.url .. '\n\n'
         .. '<u>Status</u>\n' .. indicator[state] .. ' ' .. state .. '\n\n'
         .. '<u>Location</u>\n' .. hackerspace.location.address .. '\n'

      popup = naughty.notify ({
                                 title  = hackerspace.space,
                                 text   = notify_text,
                                 width  = 200,
                                 screen = mouse.screen
                              })
   end
end

function on_mouse_leave ()
   if popup ~= nil then
      naughty.destroy (popup)
   end
end

function register (widget)
   widget:add_signal ("mouse::enter", on_mouse_enter)
   widget:add_signal ("mouse::leave", on_mouse_leave)
end


function worker (format, warg)
   if not hackerspace then
      set_hackerspace_x (warg)
   end

   hackerspace = spaceapi.get_hackerspace_data (endpoint.cache_url)
   return { name = hackerspace.space, state = get_state (hackerspace) }
end


setmetatable(_M, { __call = function(_, ...) return worker(...) end })

-- spaceapi.lua ends here
