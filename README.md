This is a OCaml CLI utility. It is a work in progress. You use it like this:

$ main.exe yarn dev

This will run the command yarn dev like normal.

But then you can press CTRL+C and a basic menu will come up where you can:
- Press CTRL+C again to exit.
- Press S to go to a shell (currently hardcoded to zsh)
- Press R to restart the original pinned command

It's basically made for me to pin a command to my WezTerm terminal panes. I plan to make it more advanced in the future. 

Let's say I'm running a command in a dev environment like a development web server. The server did not start for some reason. So you can go to the shell, correct it, exit the shell, and then the program will allow you to restart the originally command effortlessly.

NOTE: This is a work in progress. I consider it a functional prototype.

## Current known issues:
- When you exit to shell, it doesn't currently fork the shell in the background and exit. However, I kind of like the way this quirk works since I can exit to the shell and then restart the command again easily.

## Building

Libraries lwt and lwt.unix are required to build. You build the program using Dune, for example:
- dune build
- dune install

Big thank you to the OCaml Discord community for helping me out.
