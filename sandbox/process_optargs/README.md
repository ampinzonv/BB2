<!DOCTYPE html>

<html lang="en">
<head>
<meta charset="utf8"/>
<meta content="width=device-width, initial-scale=1" name="viewport"/>
<title>~tpapastylianou/process_optargs: README.md - sourcehut git</title>
<link href="/static/logo.svg" rel="icon" type="image/svg+xml"/>
<link href="/static/logo.png" rel="icon" sizes="any" type="image/png"/>
<link href="/static/main.min.a7e88522.css" rel="stylesheet"/>
<style>
pre {
  tab-size: 8
}
</style>
<meta content="git" name="vcs"/>
<meta content="https://git.sr.ht/~tpapastylianou/process_optargs" name="vcs:clone"/>
<meta content="git@git.sr.ht:~tpapastylianou/process_optargs" name="vcs:clone"/>
<meta content="https://git.sr.ht/~tpapastylianou/process_optargs" name="forge:summary"/>
<meta content="https://git.sr.ht/~tpapastylianou/process_optargs/tree/{ref}/item/{path}" name="forge:dir"/>
<meta content="https://git.sr.ht/~tpapastylianou/process_optargs/tree/{ref}/item/{path}" name="forge:file"/>
<meta content="https://git.sr.ht/~tpapastylianou/process_optargs/blob/{ref}/{path}" name="forge:rawfile"/>
<meta content="https://git.sr.ht/~tpapastylianou/process_optargs/tree/{ref}/item/{path}#L{line}" name="forge:line"/>
<meta content="git.sr.ht/~tpapastylianou/process_optargs git https://git.sr.ht/~tpapastylianou/process_optargs" name="go-import"/>
</head>
<body>
<nav class="navbar navbar-light navbar-expand-sm">
<span class="navbar-brand">
<span aria-hidden="true" class="icon icon-circle"><svg height="22" viewbox="0 0 512 512" width="22" xmlns="http://www.w3.org/2000/svg"><path d="M256 8C119 8 8 119 8 256s111 248 248 248 248-111 248-248S393 8 256 8zm0 448c-110.5 0-200-89.5-200-200S145.5 56 256 56s200 89.5 200 200-89.5 200-200 200z"></path></svg>
</span>
<a href="https://sr.ht">
    sourcehut
  </a>
</span>
<ul class="navbar-nav">
</ul>
<div class="login">
<span class="navbar-text">
<a href="https://meta.sr.ht/oauth/authorize?client_id=25ff6e5ce60d7345&amp;scopes=profile,keys,b99a95de3e69c958/jobs:write&amp;state=%2F~tpapastylianou%2Fprocess_optargs%2Ftree%2Fmain%2Fitem%2FREADME.md%3F" rel="nofollow">Log in</a>
    —
    <a href="https://meta.sr.ht">Register</a>
</span>
</div>
</nav>
<div class="header-tabbed">
<div class="container-fluid">
<h2>
<a href="/~tpapastylianou/">~tpapastylianou</a>/<wbr/>process_optargs
    </h2>
<ul class="nav nav-tabs">
<li class="nav-item">
<a class="nav-link" href="/~tpapastylianou/process_optargs">summary</a>
</li>
<li class="nav-item">
<a class="nav-link active" href="/~tpapastylianou/process_optargs/tree">tree</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~tpapastylianou/process_optargs/log">log</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~tpapastylianou/process_optargs/refs">refs</a>
</li>
</ul>
</div>
</div>
<div class="header-extension" style="margin-bottom: 0;">
<div class="blob container-fluid">
<span>
<a href="/~tpapastylianou/process_optargs/tree/main">process_optargs</a>/README.md



  
  
  <span class="text-muted" style="margin-left: 1rem">
<span title="100644">
      -rw-r--r--
    </span>
</span>
<span class="text-muted" style="margin-left: 1rem">
<span title="8041 bytes">
        7.9 KiB
      </span>
</span>
<div class="blob-nav" style="margin-left: 1rem">
<ul class="nav nav-tabs">
<li class="nav-item">
<a class="nav-link active" href="/~tpapastylianou/process_optargs/tree/main/item/README.md">View</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~tpapastylianou/process_optargs/log/main/item/README.md">Log</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~tpapastylianou/process_optargs/blame/main/README.md">Blame</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~tpapastylianou/process_optargs/blob/main/README.md">View raw</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~tpapastylianou/process_optargs/tree/915879156aff4916b53ec51b4c83486f8d2c9b10/item/README.md">Permalink</a>
</li>
</ul>
</div>
</span>
<div class="commit">
<a href="/~tpapastylianou/process_optargs/commit/main">91587915</a> —
      
      
      <a href="/~tpapastylianou/">Tasos Papastylianou</a>
      
      Add LICENSE file
      <span class="text-muted">
<span title="2023-03-21 16:36:30 UTC">4 days ago</span>
</span>
</div>
<div class="clearfix"></div>
</div>
</div>
<div class="container-fluid markdown-nav">
<ul class="nav nav-tabs">
<li class="nav-item">
<a class="nav-link active" href="?view-rendered">View Rendered</a>
</li>
<li class="nav-item">
<a class="nav-link" href="?view-source">View Source</a>
</li>
</ul>
</div>
<div class="container">
<div class="row" style="margin-right: 0;">
<div class="col-md-10 offset-md-1" style="margin-top: 1rem">
<style>.highlight { background: inherit; }</style><div class="markdown"><h2 id="process_optargs"><a href="#process_optargs" rel="nofollow noopener">#</a>process_optargs</h2>
<p>A super-simple sourceable function for processing commandline options and arguments in bash</p>
<p><em>Note: Main development for this project is done on sourcehut; however, given the
visibility and social nature of github's starring system, if you appreciate this
project and would like to express your appreciation and/or promote it on github,
then please feel free to star it on Github,
<a href="https://github.com/tpapastylianou/process_optargs" rel="nofollow noopener">here</a>.</em></p>
<h4 id="usage"><a href="#usage" rel="nofollow noopener">#</a>Usage:</h4>
<p>Used inside a (caller) function (or script) to parse its input arguments into
arguments and options.</p>
<p>The intended way to call it is with <code>"$@"</code> as the argument, which effectively
passes the caller function's input arguments down to this function for
processing. If an error occurs during the processing of arguments, it will
return a non-zero status, which can be intercepted by the caller as appropriate.</p>
<p>This function expects the following variables to be declared and initialized
locally in the caller function:</p>
<ul>
<li>An associative array called <code>OPTIONS</code>, initialized as empty</li>
<li>An indexed array called <code>ARGS</code>, initialized as empty</li>
<li>An indexed array called <code>VALID_FLAG_OPTIONS</code>, initialized as below.</li>
<li>An indexed array called <code>VALID_KEYVAL_OPTIONS</code>, initialized as below</li>
<li>A variable called <code>COMMAND_NAME</code>, initialized with the caller's name.</li>
</ul>
<p>The <code>COMMAND_NAME</code> variable should be set to the name of the caller
function/command; its purpose is to be used internally to identify the caller by
name, in the case of error messages. If it is left empty, a default ("The
Caller") is used.</p>
<p>The <code>VALID_FLAG_OPTIONS</code> and <code>VALID_KEYVAL_OPTIONS</code> arrays is where one should
specify all flag or keyval options respectively, which are valid options for the
caller function. Individual elements of these arrays could be options in either
'short' (e.g. <code>-o</code>), 'long' (e.g. <code>--optionname</code>), or 'short/long' format (e.g.
<code>-o/--optionname</code>). These arrays are inspected internally, and serve as a way to
confirm whether any flag and key/value options passed to the caller function
were valid options for that caller. If the caller takes no flag arguments, set
the <code>VALID_FLAG_OPTIONS</code> array to the empty array (i.e. <code>VALID_FLAG_OPTIONS=()</code>
); and similarly for the <code>VALID_KEYVAL_OPTIONS</code> array.</p>
<p>Note that you do not specify valid 'values' in this context, only 'keys'. Any
validation of the parsed flags and key/value pairs obtained as options via
<code>process_optargs</code> should be performed by the caller after the call to
<code>process_optargs</code>. An example which also demonstrates a simple validation scenario
is shown below.</p>
<p>The <code>OPTIONS</code> and <code>ARGS</code> arrays should ideally be initialized as empty. If not,
process_args will give a warning, but continue anyway. This allows the caller to
initialize them with predetermined options / args before the call to
<code>process_optargs</code>. <code>process_optargs</code> will then simply append any options and
arguments detected to these arrays.</p>
<p>After <code>process_optargs</code> has exited, the <code>OPTIONS</code> associative array in the caller
function will have been populated with key/value pairs; in the case of key/value
style options, the keys of the associative array will correspond to valid
'option keys' (as specified in the <code>VALID_KEYVAL_OPTIONS</code> array) in either 'short'
or 'long' form (with dashes included), depending on the particular form that
what was provided to the caller. Note that if a keyval option is provided in
both short and long form at the same time, <code>process_optargs</code> will exit with an
error, to prevent ambiguity.</p>
<p>Similarly, in the case of flag options, the associative array keys will
correspond to valid 'option flags' in either 'short' or 'long' form (with dashes
included), depending on the particular form that was provided to the caller, and
the value always set to 'On'. In this way, you can simply check if a flag
appears as a key in the associative array to see if it has been provided or not
(if it was not provided, it will simply not exist in the associative array; i.e.
do NOT expect it to exist with a value of 'Off' -- in other words, the value of
flag-based options will always be set to 'On' but otherwise it is something that
can be safely ignored). Note that, if a flag-based option is provided in both
short and long forms, while in principle there is no potential for ambiguity
(since they would both simply be set to 'On'), in practice <code>process_optargs</code> will
also treat this as an error, to prevent situations where you'd end up with the
same option appearing twice in the associative array (and thus requiring
validation a second time, which could waste computational time, or even cause
unintended bugs).</p>
<p>If an option in either short or long form appears in both the
<code>VALID_FLAG_OPTIONS</code> and <code>VALID_KEYVAL_OPTIONS</code> arrays, <code>process_optargs</code> will
exit with an error.</p>
<p>Similar to <code>OPTIONS</code>, after <code>process_optargs</code> has exited, the <code>ARGS</code> array in the
caller function will have been populated with the list of "non-option" arguments
passed to the function. As is typical with many unix tools, the special value
<code>--</code> causes any subsequent inputs to be interpreted explicitly as arguments
(i.e. even if they start with dashes and are valid option names).</p>
<p>Note that, unlike other argument parsing tool conventions, the 0-index element
of the <code>ARGS</code> array will denote the first proper argument passed to the function,
and NOT the name of the command (or function) used to call <code>process_optargs</code>.
However, if you did want this behaviour for whatever reason, since the command
(or function) name used to call <code>process_optargs</code> is meant to be captured in your
manually specified <code>COMMAND_NAME</code> variable before the call to <code>process_optargs</code>, you
can easily "append" this as the first element (i.e. at the 0-index position) of
the <code>ARGS</code> array, by simply overwriting the freshly populated <code>ARGS</code> array as
follows:</p>
<pre><code>ARGS=( "$COMMAND_NAME" "${ARGS[@]}" )
</code></pre>
<p>At the point of use, when passing arguments to your caller function, you can
combine short flags together (e.g. <code>-abc</code> instead of <code>-a -b -c</code>), use short
keyval options with or without a space (e.g. <code>-d1</code> or <code>-d 1</code> ), and long keyval
options using either a space or an equals sign without spaces (i.e. both <code>--name George</code> and <code>--name=George</code> are fine). A single dash (i.e. <code>-</code>) by itself is not
special in any way, and is treated as a normal argument (this is desired
behaviour; many unix programs which expect a filename as an argument,
traditionally accept <code>-</code> as a special "filename", denoting that the input is to
be read from the stdin instead.)</p>
<p>Dependencies: <code>error</code>, <code>warning</code>, and <code>is_in</code> functions (included in this
repository). (i.e. these need to be sourced alongside <code>process_optargs</code> in your
project, for <code>process_optargs</code> to work). Alternatively, append them to this file
and source only the <code>process_optargs</code> file in your project.</p>
<p>Example use:</p>
<pre><code>source /path/to/process_optargs
source /path/to/error
source /path/to/warning
source /path/to/is_in

function myfunction () {    # The function whose options/args we want to process

 # Initialise the necessary variables that will be checked / populated by process_optargs
   local -A OPTIONS=()
   local -a ARGS=()
   local -a VALID_FLAG_OPTIONS=( -h/--help -v --version )    # note -v and --version represent separate flags here! (e.g. '-v' could be for 'verbose')
   local -a VALID_KEYVAL_OPTIONS=( -r/--repetitions )
   local COMMAND_NAME="myfunction"

 # Perform the processing to populate the OPTIONS and ARGS arrays.
   process_optargs "$@" || exit 1

 # Validate parsed options and arguments
   if is_in '-h' "${!OPTIONS[@]}" || is_in '--help' "${!OPTIONS[@]}"
   then display_help
   fi

   if   is_in '-r'            "${!OPTIONS[@]}"; then REPS="${OPTIONS[-r]}"
   elif is_in '--repetitions' "${!OPTIONS[@]}"; then REPS="${OPTIONS[--repetitions]}"
   fi

   if   test "${#ARGS[@]}" -lt 2
   then error "myfunction requires at least 2 non-option arguments"
        exit 1
   fi

   # ...etc
}
</code></pre>
</div>
</div>
</div>
<script src="/static/linelight.js"></script>
</div></body>
</html>