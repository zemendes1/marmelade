-- Rex configuration: https://www.superlogical.com/rex/docs/customize/config

-- Option+1..9 goes to tab N. AeroSpace takes Cmd+1..8 for workspaces, so
-- Rex's default Cmd+1..9 tab shortcuts never reach the app.
for i = 1, 9 do
  rex.bind("alt+[Digit" .. i .. "]", "client.tab.goto", { index = i })
end
