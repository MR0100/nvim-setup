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








--------------- [ TMUX CHEATSHEET ] ----------------

z# Tmux Cheat Sheet

## 🧭 Basic Concepts
- **Session**: Group of windows.
- **Window**: Like a tab; contains one or more panes.
- **Pane**: Split inside a window (horizontal/vertical).

> Default prefix key: `Ctrl + b`

---

## 🚀 Everyday Commands

| Action           | Key Binding / Command            |
|------------------|----------------------------------|
| Start tmux       | `tmux`                           |
| New session      | `tmux new -s <session-name>`     |
| Detach session   | `Ctrl+b` then `d`                |
| List sessions    | `tmux ls`                        |
| Attach session   | `tmux attach -t <session-name>`  |
| Kill session     | `tmux kill-session -t <name>`    |

---

## 🪟 Window Commands

| Action             | Key Binding / Command  |
|--------------------|------------------------|
| New window         | `Ctrl+b` then `c`      |
| Next window        | `Ctrl+b` then `n`      |
| Previous window    | `Ctrl+b` then `p`      |
| Rename window      | `Ctrl+b` then `,`      |
| Close window       | `exit` or `Ctrl+d`     |
| Move window        | `Ctrl+b` then \`.`     |

---

## 🔲 Pane Commands

| Action             | Key Binding               |
|--------------------|---------------------------|
| Split horizontally | `Ctrl+b` then `"`         |
| Split vertically   | `Ctrl+b` then `%`         |
| Switch panes       | `Ctrl+b` then arrow keys  |
| Resize panes       | `Ctrl+b` then `Ctrl+arrow`|
| Close pane         | `exit` or `Ctrl+d`        |

---

## 🧠 Session Management

```bash
tmux new -s mysession            # Create new session
tmux attach -t mysession         # Attach to session
tmux kill-session -t mysession   # Kill session
tmux rename-session -t old new   # Rename session







------------------------ EOD ----------------------------



















