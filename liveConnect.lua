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
local http = require("http")


-- Cache responses
local lastResponse;
local last = {};

function Main()

    local seqNo = TextInput("Enter sequence number", 1);
    if(not seqNo or not tonumber(seqNo)) then Error("Invalid sequence number"); return; end;
    local seq = Root().ShowData.DataPools.Default.Sequences[tonumber(seqNo)];
    if(not seq.no) then Error("Sequence does not exist"); return; end;

    local codeNo = TextInput("Enter timecode number", 1);
    if(not codeNo or not tonumber(codeNo)) then Error("Invalid timecode number"); return; end;
    local code = Root().ShowData.DataPools.Default.Sequences[tonumber(codeNo)];
    if(not code.no) then Error("Timecode does not exist"); return; end;
    
    -- while(true) do (function()
  
      local response = http.request('http://localhost:18080/_/MARKER');
      if(response == lastResponse) then return; end; -- no changes to effect 

      for name, i, time, color in response:gmatch('MARKER\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\t]+)\n') do
        local cueRef = "Sequence " .. seqNo .. " Cue " .. i;
        if(last[i] ~= time) then
          print("Marker %s at %s: %s", i, time, name)
          if (seq.name == "Sequence "..seq.no) then
            Cmd('Set Timecode ' .. code.no .. '.*."<Sequence ' .. seq.no .. '>".*.*.' .. i .. ' Property Time ' .. time)
          else
            Cmd('Set Timecode ' .. code.no .. '.*."' .. seq.name .. '".*.*.' .. i .. ' Property Time ' .. time)
          end
        end; last[i] = time;  
      end; lastResponse = response;
  
    -- end)() end;
  
  end

-- Main Loop
return Main