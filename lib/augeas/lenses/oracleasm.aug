module Oracleasm =
  autoload xfm

  let eol = Util.eol

  let key_re = /[A-Za-z0-9_]+(\[[0-9]+\])?/ - "unset" - "export"
  let eq = Util.del_str "="
  let comment = Util.comment
  let comment_or_eol = Util.comment_or_eol
  let empty   = Util.empty
  let xchgs   = Build.xchgs

  let char  = /[^#() '"\t\n]|\\\\"/
  let dquot = /"([^"\\\n]|\\\\.)*"/                    (* " Emacs, relax *)
  let squot = /'[^'\n]*'/
  (* For some reason, `` conflicts with comment_or_eol *)
  let bquot = /`[^#`\n]*`/

  (* Array values of the form '(val1 val2 val3)'. We do not handle empty *)
  (* arrays here because of typechecking headaches. Instead, they are    *)
  (* treated as a simple value                                           *)
  let array =
    let array_value = store (char+ | dquot) in
    del /\([ \t]*/ "(" . counter "values" .
      [ seq "values" . array_value ] .
      [ del /[ \t\n]+/ " " . seq "values" . array_value ] *
      . del /[ \t]*\)/ ")"

  (* Treat an empty list () as a value '()'; that's not quite correct *)
  (* but fairly close.                                                *)
  let simple_value =
    let empty_array = /\([ \t]*\)/ in
      store (char* | dquot | squot | bquot | empty_array)

  let export = [ key "export" . Util.del_ws_spc ]
  let kv = [ export? . key key_re . eq . (simple_value | array) . comment_or_eol ]

  let var_action (name:string) =
    [ xchgs name ("@" . name) . Util.del_ws_spc . store key_re . comment_or_eol ]

  let unset = var_action "unset"
  let bare_export = var_action "export"

  let source =
    [
      del /\.|source/ "." . label ".source" .
      Util.del_ws_spc . store /[^= \t\n]+/ . eol
    ]

  let shell_builtin_cmds = "ulimit"

  let builtin =
    [ label "@builtin"
      . store shell_builtin_cmds
      . Util.del_ws_spc
      . [ label "args" . store /[^ \t\n][^;\n]+[^ \t\n]|[^ \t;\n]+/ ]
      . eol ]

  let lns = (comment | empty | source | kv | unset | bare_export | builtin) *

  let filter      = incl "/etc/sysconfig/oracleasm"

  let xfm         = transform lns filter

(* Local Variables: *)
(* mode: caml       *)
(* End:             *)
