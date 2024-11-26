{ exec, ... }:

let
  bashScript = script: [ "bash" "-c" script ];
  run = command: bashScript ''
    echo '"'$(${command})'"'
  '';
in
{
  gcloudToken = exec (run "gcloud auth print-access-token");
}
