local print = Printf;
local function Error(m)
    local options = {
        title="Error",
        message=m,
        commands={
            {value=0, name="OKAY"}
        }
    }
    local r = MessageBox(options)
end;

-- Load HTTP package
package.preload['mime.core'] = function() return {}; end;
--[[
  To make the http package work changes to the requirements/http.lua are required:
  
  local url = require("socket.url") -->> local url = require("url")
  local headers = require("socket.headers") -->> local headers = require("headers")
]]--
local http = require("http")


-- Cache responses
local lastResponse;
local last = {};

function Main()

    local seqNo = TextInput("Enter sequence number", 1);
    if(not seqNo or not tonumber(seqNo)) then Error("Invalid sequence number"); return; end;
    local seq = Root().ShowData.DataPools.Default.Sequences[tonumber(seqNo)];
    if(not seq.no) then Error("Sequence does not exist"); return; end;
    
    -- while(true) do (function()
  
      local response = http.request('http://localhost:18080/_/MARKER');
      if(response == lastResponse) then return; end; -- no changes to effect 
   
      for name, i, time in response:gmatch('MARKER\t([^\t]+)\t([^\t]+)\t([^\t]+)') do
        local cueRef = "Sequence " .. seqNo .. " Cue " .. i;
        if(last[i] ~= time) then
          Printf('Assign %s /Trig="Timecode" /TrigTime=%s', cueRef, tonumber(time));
          -- gma.cmd(string.format('Assign %s /Trig="Timecode" /TrigTime=%s', cueRef, tonumber(time)));
        end; last[i] = time;  
      end; lastResponse = response;
  
    -- end)() end;
  
  end

-- Main Loop
return Main