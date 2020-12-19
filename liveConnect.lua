-- define helper functions
local print = Printf
local function Error(m)
  local options = {
    title = "Error",
    message = m,
    commands = {{
      value = 0,
      name = "OKAY"
    }}
  }
  local r = MessageBox(options)
end

-- load HTTP package
local http = require("http")

-- cache responses
local lastResponse
local last = {}

-- define main function
function Main()

  -- get sequence number by user input 
  local seqNo = TextInput("Enter sequence number", 1)
  if (not seqNo or not tonumber(seqNo)) then
    Error("Invalid sequence number")
    return
  end
  -- validate user input for sequence number
  local seq = Root().ShowData.DataPools.Default.Sequences[tonumber(seqNo)]
  if (not seq.no) then
    Error("Sequence does not exist")
    return
  end

  -- get timecode number by user input
  local codeNo = TextInput("Enter timecode number", 1)
  if (not codeNo or not tonumber(codeNo)) then
    Error("Invalid timecode number")
    return
  end
  -- validate user input for timecode number
  local code = Root().ShowData.DataPools.Default.Sequences[tonumber(codeNo)]
  if (not code.no) then
    Error("Timecode does not exist")
    return
  end

  -- define loop for continuous sychronisation with reaper
  while true do

    -- get marker response from reaper
    local response = http.request('http://localhost:18080/_/MARKER')

    -- pasrse response and tell MA3 about changes
    for name, i, time, color in response:gmatch('MARKER\t([^\t]*)\t([^\t]+)\t([^\t]+)\t([^\t]+)\n') do
      local cueRef = "Sequence " .. seqNo .. " Cue " .. i
      if (last[i] ~= time) then
        print("Marker %s at %s: %s", i, time, name)
        if (seq.name == "Sequence " .. seq.no) then
          Cmd('Set Timecode ' .. code.no .. '.*."<Sequence ' .. seq.no .. '>".*.*.' .. i .. ' Property Time ' .. time)
        else
          Cmd('Set Timecode ' .. code.no .. '.*."' .. seq.name .. '".*.*.' .. i .. ' Property Time ' .. time)
        end
      end
      last[i] = time
    end
    lastResponse = response

    -- let other processes continue their job for 3 seconds till checking back with reaper agian
    coroutine.yield(3)
  end

end

-- run main funtion
return Main
