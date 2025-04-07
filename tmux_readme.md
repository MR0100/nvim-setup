### install tmux

- `brew install tmux`

### using `oh my tmux`

- `git clone https://github.com/gpakosz/.tmux.git ~/.tmux` 
    - this will download the tmux inside the roor (~) with folder named ".tmux". 

- `ln -s -f ~/.tmux/.tmux.conf ~/`
    - ln : create link (alias), create link to that file in the (~/) root. 
    - -s : create symbolic link
    - -f : force
    - ~/.tmux/.tmux.conf : source file
    - ~/ : location (root)

- `cp ~/.tmux/.tmux.conf.local ~/`
    - cp : copy file
    - ~/.tmux/.tmux.conf.local : source file
    - ~/ : location (root)


### Reload the config

- `tmux source-file ~/.tmux.conf`


### keybindings
- `C-a`                 : Prefix Key (alias:<p>)
- `<p>-`                : Split Verticle
- `<p>|`                : Split Horizontale
- `<p>h/j/k/l`          : Move Between Panes (Left, Down, Up, Right)
- `<p>d`                : Detach Session


### Commands

- `tmux`                        : Create new unknown Session
- `tmux new -s [name]`          : Create new Session with Custom Name.
- `tmux ls`                     : list all the tmux sessions
- `tmux attach`                 : ReAttach Session
- `tmux attach -t [name]`       : ReAttach to a Session with Provided Name. 
- `tmux kill-session -t [name]` : Kill a Specific tmux Session. 
- `tmux kill-server`            : Kill all the existing tmux Sessions. 
    (Be Careful before using this command, it will kill all the sessions and those might be important. so, check the sessions before killing all)

