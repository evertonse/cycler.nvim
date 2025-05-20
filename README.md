# Cycler

Cycle between `false` to `true`, from `public` to `private`, use a function to cycle from 1 to 2 then 2 to 3 and so on, similar to vim's builtin `<C-a>` but can do whatevs in from `lua`.

<!-- Useful for those who remaped tmux <C-a> instead of <C-b> -->


```lua
return {
  'evertonse/cycler.nvim',
  event = 'BufReadPost',
  config = function()
    require('cycler').setup {
      cycles = {
        { '==', '!=' },
        { 'true', 'false' },
        { 'False', 'True' },
        { 'public', 'private' },
        { 'disable', 'enable' },
        { 'if', 'else', 'elseif' },
        { 'and', 'or' },
        { 'off', 'on' },
        { 'yes', 'no' },
        function(text)
          local ok, num = pcall(tonumber, text)
          if ok then
            return tostring(num + 1)
          end
          return nil -- fallback
        end,
    }
    vim.keymap.set('n', '<C-x>', function()
      require('cycler').cycle()
    end)
  end,
}
```

# References
This is a fork of you can see on the thing on github
