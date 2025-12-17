open Lwt.Infix

let adjust_term_io _ =
  let fd = Lwt_unix.unix_file_descr Lwt_unix.stdin in
  (* Get current terminal settings *)
  let term_io = Unix.tcgetattr fd in

  (* Modify settings: disable canonical mode (cbreak mode) and echo *)
  let new_term_io =
    { term_io with Unix.c_icanon = false; Unix.c_echo = false }
  in

  (* Apply new settings *)
  (* Unix.tcsetattr fd Unix.TCSAFLUSH new_term_io;*)
  Unix.tcsetattr fd Unix.TCSANOW new_term_io;
  ()

let read_char_without_newline _ =
  (* Read a single character asynchronously *)
  let p = Lwt_io.read_char Lwt_io.stdin in
  p
(* Restore original settings after the promise is fulfilled 
  Lwt.finalize
    (fun () -> p)
    (fun () ->
      Unix.tcsetattr fd Unix.TCSAFLUSH term_io;
      Lwt.return_unit)*)

let run_command cmd =
  Lwt_process.with_process_none ("", cmd) (fun _ ->
      adjust_term_io ();
      Lwt.return_unit)
(*fun process ->
      let input_channel = process#stdout in

      (* A recursive Lwt function to read lines one by one until the end of the stream *)
      let rec read_lines_lwt () =
        Lwt_io.read_char_opt input_channel >>= function
        | Some c ->
            (* Print the line to the console (Lwt_io.printf is asynchronous) *)
            Lwt_io.write_char Lwt_io.stdout c >>=
            read_lines_lwt (* Continue reading the next line *)
        | None ->
            (* End of stream reached, return an empty promise *)
            Lwt.return_unit
      in

      (* Start reading lines and wait for the process to finish *)
      read_lines_lwt ()
    *)

(*let command = ("", cmd) in
Lwt_process.with_process_full command (fun p ->
Lwt_io.read p#stdout) >>= fun s ->
Lwt_io.write Lwt_io.stdout s*)

let cmd = Array.of_list (List.tl (Array.to_list Sys.argv))

let wait_for_signal () =
  let promise, resolve = Lwt.wait () in
  Sys.set_signal Sys.sigint
    (Signal_handle
       (fun _ ->
         Sys.set_signal Sys.sigint Signal_default;
         Lwt.wakeup_later resolve ()));
  promise

let rec on_terminated () =
  adjust_term_io ();
  Sys.set_signal Sys.sigint Signal_default;
  Lwt_io.write_line Lwt_io.stdout
    "Program terminated: (R)estart, Exit to (S)hell. Press CTRL+C to exit."
  |> ignore;
  read_char_without_newline () >>= fun c ->
  match c with
  | 'r' | 'R' ->
      Lwt.pick [ run_command cmd; wait_for_signal () ] >>= fun _ ->
      on_terminated ()
  | 's' | 'S' ->
      run_command [| "/bin/zsh"; "-i" |] >>= fun _ -> on_terminated ()
  | _ -> on_terminated ()

let main_promise = Lwt.pick [ run_command cmd; wait_for_signal () ]
let run_or_interrupt = main_promise >>= fun _ -> on_terminated ()

let main _ =
  adjust_term_io ();
  Lwt_main.run run_or_interrupt

let () = main ()
