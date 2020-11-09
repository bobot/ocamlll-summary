open Core
open Core_bench

let read_direct file = In_channel.read_all file

let read_cat file =
  let cat = Unix.create_process ~prog:"cat" ~args:[file] in
  Unix.close cat.stdin;
  let s = In_channel.input_all (Unix.in_channel_of_descr cat.stdout) in
  Unix.close cat.stdout;
  Unix.close cat.stderr;
  ignore (Unix.wait (`Pid cat.pid));
  s

let file = "bench_read.ml"

let oracle = String.length (read_direct file)

let read_direct = Bench.Test.create
  ~name:"read_direct"
  (fun () -> assert (String.length (read_direct file) = oracle))

let read_cat = Bench.Test.create
  ~name:"read_cat"
  (fun () -> assert (String.length (read_cat file) = oracle))

let tests = [ read_direct; read_cat ]

let () = Command.run (Bench.make_command tests)
