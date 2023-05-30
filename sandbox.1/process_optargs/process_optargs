   function process_optargs () {
    ################################################################################################
    #
    # Used inside a (caller) function (or script) to parse its input arguments
    # into arguments and options.
    #
    # The intended way to call it is with "$@" as the argument, which effectively passes the caller
    # function's input arguments down to this function for processing. If an error occurs during the
    # processing of arguments, it will return a non-zero status, which can be intercepted by the
    # caller as appropriate.
    #
    # This function expects the following variables to be declared and initialized locally in the
    # caller function:
    #
    #  • An associative array called OPTIONS, initialized as empty
    #  • An indexed array called ARGS, initialized as empty
    #  • An indexed array called VALID_FLAG_OPTIONS, initialized as below.
    #  • An indexed array called VALID_KEYVAL_OPTIONS, initialized as below
    #  • A variable called COMMAND_NAME, initialized with the caller's name.
    #
    # The COMMAND_NAME variable should be set to the name of the caller function/command; its
    # purpose is to be used internally to identify the caller by name, in the case of error
    # messages. If it is left empty, a default ("The Caller") is used.
    #
    # The VALID_FLAG_OPTIONS and VALID_KEYVAL_OPTIONS arrays is where one should specify all flag or
    # keyval options respectively, which are valid options for the caller function. Individual
    # elements of these arrays could be options in either 'short' (e.g. '-o'), 'long' (e.g.
    # '--optionname'), or 'short/long' format (e.g. '-o/--optionname'). These arrays are inspected
    # internally, and serve as a way to confirm whether any flag and key/value options passed to the
    # caller function were valid options for that caller. If the caller takes no flag arguments, set
    # the VALID_FLAG_OPTIONS array to the empty array (i.e. VALID_FLAG_OPTIONS=() ); and similarly
    # for the VALID_KEYVAL_OPTIONS array.
    #
    # Note that you do not specify valid 'values' in this context, only 'keys'. Any validation of
    # the parsed flags and key/value pairs obtained as options via process_optargs should be
    # performed by the caller after the call to process_optargs. An example which also demonstrates
    # a simple validation scenario is shown below.
    #
    # The OPTIONS and ARGS arrays should ideally be initialized as empty. If not, process_args will
    # give a warning, but continue anyway. This allows the caller to initialize them with
    # predetermined options / args before the call to process_optargs. process_optargs will then
    # simply append any options and arguments detected to these arrays.
    #
    # After process_optargs has exited, the OPTIONS associative array in the caller function will
    # have been populated with key/value pairs; in the case of key/value style options, the keys of
    # the associative array will correspond to valid 'option keys' (as specified in the
    # VALID_KEYVAL_OPTIONS array) in either 'short' or 'long' form (with dashes included), depending
    # on the particular form that what was provided to the caller. Note that if a keyval option is
    # provided in both short and long form at the same time, process_optargs will exit with an
    # error, to prevent ambiguity.
    #
    # Similarly, in the case of flag options, the associative array keys will correspond to valid
    # 'option flags' in either 'short' or 'long' form (with dashes included), depending on the
    # particular form that was provided to the caller, and the value always set to 'On'. In this
    # way, you can simply check if a flag appears as a key in the associative array to see if it has
    # been provided or not (if it was not provided, it will simply not exist in the associative
    # array; i.e. do NOT expect it to exist with a value of 'Off' -- in other words, the value of
    # flag-based options will always be set to 'On' but otherwise it is something that can be safely
    # ignored). Note that, if a flag-based option is provided in both short and long forms, while in
    # principle there is no potential for ambiguity (since they would both simply be set to 'On'),
    # in practice process_optargs will also treat this as an error, to prevent situations where
    # you'd end up with the same option appearing twice in the associative array (and thus requiring
    # validation a second time, which could waste computational time, or even cause unintended
    # bugs).
    #
    # If an option in either short or long form appears in both the VALID_FLAG_OPTIONS and
    # VALID_KEYVAL_OPTIONS arrays, process_optargs will exit with an error.
    #
    # Similar to OPTIONS, after process_optargs has exited, the ARGS array in the caller function
    # will have been populated with the list of "non-option" arguments passed to the function. As is
    # typical with many unix tools, the special value '--' causes any subsequent inputs to be
    # interpreted explicitly as arguments (i.e. even if they start with dashes and are valid option
    # names).
    #
    # Note that, unlike other argument parsing tool conventions, the 0-index element of the ARGS
    # array will denote the first proper argument passed to the function, and NOT the name of the
    # command (or function) used to call process_optargs. However, if you did want this behaviour
    # for whatever reason, since the command (or function) name used to call process_optargs is
    # meant to be captured in your manually specified COMMAND_NAME variable before the call to
    # process_optargs, you can easily "append" this as the first element (i.e. at the 0-index
    # position) of the ARGS array, by simply overwriting the freshly populated ARGS array as
    # follows:
    #
    #     ARGS=( "$COMMAND_NAME" "${ARGS[@]}" )
    #
    #
    # At the point of use, when passing arguments to your caller function, you can combine short
    # flags together (e.g. '-abc' instead of '-a -b -c'), use short keyval options with or without a
    # space (e.g. '-d1' or '-d 1' ), and long keyval options using either a space or an equals sign
    # without spaces (i.e. both '--name George' and '--name=George' are fine). A single dash (i.e.
    # '-') by itself is not special in any way, and is treated as a normal argument (this is
    # desired behaviour; many unix programs which expect a filename as an argument, traditionally
    # accept '-' as a special "filename", denoting that the input is to be read from the stdin
    # instead.)
    #
    # Dependencies: 'error', 'warning', and 'is_in' functions from TazUtils. (i.e. these need to be
    # sourced alongside process_optargs in your project, for process_optargs to work)
    #
    #
    # Example use:
    #
    #     source /path/to/TazUtils/process_optargs
    #     source /path/to/TazUtils/error
    #     source /path/to/TazUtils/warning
    #     source /path/to/TazUtils/is_in
    #
    #     function myfunction () {
    #
    #        local -A OPTIONS=()
    #        local -a ARGS=()
    #        local -a VALID_FLAG_OPTIONS=( -h/--help -v --version )    # note -v and --version represent separate flags here! (e.g. '-v' could be for 'verbose')
    #        local -a VALID_KEYVAL_OPTIONS=( -r/--repetitions )
    #        local COMMAND_NAME="myfunction"
    #
    #        process_optargs "$@" || exit 1
    #
    #      # Validate parsed options and arguments
    #        if is_in '-h' "${!OPTIONS[@]}" || is_in '--help' "${!OPTIONS[@]}"
    #        then display_help
    #        fi
    #
    #        if   is_in '-r'            "${!OPTIONS[@]}"; then REPS="${OPTIONS[-r]}"
    #        elif is_in '--repetitions' "${!OPTIONS[@]}"; then REPS="${OPTIONS[--repetitions]}"
    #        fi
    #
    #        if   test "${#ARGS[@]}" -lt 2
    #        then error "myfunction requires at least 2 non-option arguments"
    #             exit 1
    #        fi
    #
    #        # ...etc
    #     }
    #
    #
    ################################################################################################



    # --------------------------------------------------------------------------
    # Assert that preconditions have been met before calling this function
    # (issue warnings for 'soft' preconditions)
    # --------------------------------------------------------------------------

    # Assert COMMAND_NAME has been declared in the caller
      if   declare -p COMMAND_NAME > /dev/null 2> /dev/null
      then :
      else error "Error: The COMMAND_NAME variable has not been declared in the caller."  && return 1
      fi

    # Check if COMMAND_NAME has been set; if not, warn and set to a default value.
      if   test -n "${COMMAND_NAME}"
      then COMMAND_NAME_WITH_PARENS=" ($COMMAND_NAME)"
      else warning "Warning: The COMMAND_NAME variable was declared in the caller as empty; setting COMMAND_NAME=\"The Caller\""
           COMMAND_NAME_WITH_PARENS=
           COMMAND_NAME="The Caller"
      fi

    # Assert OPTIONS has been declared in the caller
      if   declare -p OPTIONS > /dev/null 2> /dev/null
      then :
      else error "Error: The OPTIONS variable has not been declared in the caller${COMMAND_NAME_WITH_PARENS}." && return 1
      fi

    # Assert OPTIONS has been declared specifically as an associative array in the caller
      if   test "$( declare -p OPTIONS | cut -d' ' -f2 )" = "-A"
      then :
      else error "Error: The OPTIONS variable has not been declared as an associative array in the caller${COMMAND_NAME_WITH_PARENS}." && return 1
      fi

    # Check if the OPTIONS array is empty; if not, warn appropriately.
      if   test "${#OPTIONS[@]}" -eq 0
      then :
      else warning "Warning: The OPTIONS associative array as declared in the caller${COMMAND_NAME_WITH_PARENS} is non-empty."
      fi

    # Assert ARGS has been declared in the caller
      if   declare -p ARGS > /dev/null 2> /dev/null
      then :
      else error "Error: The ARGS variable has not been declared in the caller${COMMAND_NAME_WITH_PARENS}." && return 1
      fi

    # Assert ARGS has been declared specifically as an indexed array in the caller
      if   test "$( declare -p ARGS | cut -d' ' -f2 )" = "-a"
      then :
      else error "Error: The ARGS variable has not been declared as an indexed array in the caller${COMMAND_NAME_WITH_PARENS}." && return 1
      fi

    # Check if the ARGS array is empty; if not warn, appropriately.
      if   test "${#ARGS[@]}" -eq 0
      then :
      else warning "Warning: The ARGS indexed array as declared in the caller${COMMAND_NAME_WITH_PARENS} is non-empty."
      fi

    # Assert VALID_FLAG_OPTIONS has been declared in the caller
      if   declare -p VALID_FLAG_OPTIONS > /dev/null 2> /dev/null
      then :
      else error "Error: The VALID_FLAG_OPTIONS variable has not been declared in the caller${COMMAND_NAME_WITH_PARENS}." && return 1
      fi

    # Assert VALID_FLAG_OPTIONS has been declared specifically as an indexed array in the caller
      if   test "$( declare -p VALID_FLAG_OPTIONS | cut -d' ' -f2 )" = "-a"
      then :
      else error "Error: The VALID_FLAG_OPTIONS variable has not been declared as an indexed array in the caller${COMMAND_NAME_WITH_PARENS}." & return 1
      fi

    # Assert VALID_KEYVAL_OPTIONS has been declared in the caller
      if   declare -p VALID_KEYVAL_OPTIONS > /dev/null 2> /dev/null
      then :
      else error "Error: The VALID_KEYVAL_OPTIONS variable has not been declared in the caller${COMMAND_NAME_WITH_PARENS}." && return 1
      fi

    # Assert VALID_KEYVAL_OPTIONS has been declared specifically as an indexed array in the caller
      if   test "$( declare -p VALID_KEYVAL_OPTIONS | cut -d' ' -f2 )" = "-a"
      then :
      else error "Error: The VALID_KEYVAL_OPTIONS variable has not been declared as an indexed array in the caller${COMMAND_NAME_WITH_PARENS}." & return 1
      fi

    # Assert no option appears as both a flag and a keyval option.
      for  FLAG_OPT in "${VALID_FLAG_OPTIONS[@]}"
      do
         # check short forms first
           if   test -n "${FLAG_OPT%/*}"
           then for  KEYVAL_OPT in "${VALID_KEYVAL_OPTIONS[@]}"
                do   if   test "${KEYVAL_OPT%/*}" = "${FLAG_OPT%/*}"
                     then error "Error: option '${FLAG_OPT%/*}' cannot be specified in '$COMMAND_NAME' as both a flag and keyval option (i.e. as a member of both VALID_FLAG_OPTIONS and VALID_KEYVAL_OPTIONS at the same time)" && return 1
                     fi
                done
           fi

         # check long forms second
           if   test -n "${FLAG_OPT#*/}"
           then for  KEYVAL_OPT in "${VALID_KEYVAL_OPTIONS[@]}"
                do   if   test "${KEYVAL_OPT#*/}" = "${FLAG_OPT#*/}"
                     then error "Error: option '${FLAG_OPT#*/}' cannot be specified in '$COMMAND_NAME' as both a flag and keyval option (i.e. as a member of both VALID_FLAG_OPTIONS and VALID_KEYVAL_OPTIONS at the same time)" && return 1
                     fi
                done
           fi
      done



    # Define helper local variables
      local OPTION_KEY                      # Holds a 'key' string when populating the OPTIONS associative array with an option token
      local OPTION_VALUE                    # Holds a 'value' when populating the OPTIONS associative array with an option token
      local OPTION_SHIFT                    # Used to remove the appropriate number of tokens from the list of input arguments, after an option has been processed.
      local STILL_PROCESSING_OPTIONS=true   # Turned 'off' when '--' is passed as an argument
      local -a VALID_SHORT_FLAG_OPTIONS     # An array that will hold all the valid short flags
      local -a VALID_LONG_FLAG_OPTIONS      # An array that will hold all the valid long flags
      local -a VALID_SHORT_KEYVAL_OPTIONS   # An array that will hold the short form of all valid key-value option keys
      local -a VALID_LONG_KEYVAL_OPTIONS    # An array that will hold the long form of all valid key-value option keys
      local +n FLAG_OR_KEYVAL_LIST          # A helper variable to be later used as a 'nameref' variable, pointing to either VALID_FLAG_OPTIONS or VALID_KEYVAL_OPTIONS as appropriate
      local +n SHORT_FLAG_OR_KEYVAL_LIST    # A helper variable to be later used as a 'nameref' variable, pointing to either VALID_SHORT_FLAG_OPTIONS or VALID_SHORT_KEYVAL_OPTIONS as appropriate
      local +n LONG_FLAG_OR_KEYVAL_LIST     # A helper variable to be later used as a 'nameref' variable, pointing to either VALID_LONG_FLAG_OPTIONS or VALID_LONG_KEYVAL_OPTIONS as appropriate


    # Split VALID_FLAG_OPTIONS and VALID_KEYVAL_OPTIONS arrays into their
    # respective SHORT/LONG equivalents; also ensure the two arrays have the
    # correct format in the process, otherwise exit with an informative error.
      for FLAG_OR_KEYVAL_LIST in "VALID_FLAG_OPTIONS" "VALID_KEYVAL_OPTIONS"
      do

        # Convert to appropriate namerefs, to help iterate over both flags and keyvals
          if   test "$FLAG_OR_KEYVAL_LIST" = "VALID_FLAG_OPTIONS"
          then SHORT_FLAG_OR_KEYVAL_LIST="VALID_SHORT_FLAG_OPTIONS"
               LONG_FLAG_OR_KEYVAL_LIST="VALID_LONG_FLAG_OPTIONS"
          else SHORT_FLAG_OR_KEYVAL_LIST="VALID_SHORT_KEYVAL_OPTIONS"
               LONG_FLAG_OR_KEYVAL_LIST="VALID_LONG_KEYVAL_OPTIONS"
          fi

          local -n FLAG_OR_KEYVAL_LIST
          local -n SHORT_FLAG_OR_KEYVAL_LIST
          local -n LONG_FLAG_OR_KEYVAL_LIST


        # Validate and split to appropriate lists
          for  TOKEN in "${FLAG_OR_KEYVAL_LIST[@]}"
          do

             # Check if token is paired or singular, and process accordingly
               NUMBER_OF_SLASHES="$( echo "$TOKEN" | tr -cd / | wc -c )"

               if   test "$NUMBER_OF_SLASHES" -eq 0   # i.e. token is singular (a.k.a. unpaired)
               then

                  # Check if singular token has a correct form
                    if   test "${#TOKEN}" -eq 2 && test "$( echo "$TOKEN" | tr -s [:alpha:] Y )" = "-Y"   # token is of form '-x' (where x is a single letter denoting a short flag)
                    then SHORT_FLAG_OR_KEYVAL_LIST[${#SHORT_FLAG_OR_KEYVAL_LIST[@]}]="$TOKEN"
                    elif test "${TOKEN:0:2}" = "--" && test "$( echo "${TOKEN:2}" | tr -s [:alpha:] Y )" = "Y"   # token is of form '--optionname'
                    then LONG_FLAG_OR_KEYVAL_LIST[${#LONG_FLAG_OR_KEYVAL_LIST[@]}]="$TOKEN"
                    else local +n FLAG_OR_KEYVAL_LIST
                         error "Error: token '$TOKEN' as specified in $FLAG_OR_KEYVAL_LIST does not appear to be a valid option token (e.g. '-o' or '--optionname') or short/long option pair (e.g. '-o/--one')" && return 1
                    fi

               elif test "$NUMBER_OF_SLASHES" -eq 1   # i.e. token is paired (two valid option tokens divided by a slash, as shortform/longform, e.g. '-o/--optionname')
               then

                  # Check if the pair has been provided appropriately as short/long pair
                    LTOKEN="${TOKEN%/*}"   # Remove everything after the slash (inclusive)
                    RTOKEN="${TOKEN#*/}"   # Remove everything prior to the slash (inclusive)
                    if   test "${#LTOKEN}" -eq 2                                   \
                         && test "$( echo "$LTOKEN" | tr -s [:alpha:] Y )" = "-Y"  \
                         && test "${RTOKEN:0:2}" = "--"                            \
                         && test "$( echo "${RTOKEN:2}" | tr -s [:alpha:] Y )" = "Y"
                    then SHORT_FLAG_OR_KEYVAL_LIST[${#SHORT_FLAG_OR_KEYVAL_LIST[@]}]="$LTOKEN"
                         LONG_FLAG_OR_KEYVAL_LIST[${#LONG_FLAG_OR_KEYVAL_LIST[@]}]="$RTOKEN"
                    else local +n FLAG_OR_KEYVAL_LIST
                         error "Error: token '$TOKEN' as specified in $FLAG_OR_KEYVAL_LIST does not appear to be a valid option token (e.g. '-o' or '--optionname') or short/long option pair (e.g. '-o/--one')" && return 1
                    fi

               else   # More than one slashes detected: invalid token (neither singular nor paired).

                    local +n FLAG_OR_KEYVAL_LIST
                    error "Error: token '$TOKEN' as specified in $FLAG_OR_KEYVAL_LIST does not appear to be a valid option token (e.g. '-o' or '--optionname') or short/long option pair (e.g. '-o/--one')" && return 1
               fi
          done


        # Ensure variables can be assigned new namerefs in the next iteration (rather than overwrite the variables they refer to!)
          local +n FLAG_OR_KEYVAL_LIST
          local +n SHORT_FLAG_OR_KEYVAL_LIST
          local +n LONG_FLAG_OR_KEYVAL_LIST

      done


    # Start processing provided tokens
      while test ${#@} -gt 0
      do
          # Stop processing options if given '--' by itself
            if   test "$1" = "--"
            then STILL_PROCESSING_OPTIONS=false
                 shift && continue

          # Process flag option in long form if valid
            elif $STILL_PROCESSING_OPTIONS &&
                 test "${1:0:2}" = "--"   &&
                 is_in "$1" "${VALID_LONG_FLAG_OPTIONS[@]}"
            then OPTION_KEY="$1"; OPTION_VALUE="On"; OPTION_SHIFT=1

          # Process key-value option in long form if valid
            elif $STILL_PROCESSING_OPTIONS &&
                 test "${1:0:2}" = "--"   &&
                 is_in "${1%=*}" "${VALID_LONG_KEYVAL_OPTIONS[@]}"
            then if   test "$( echo "$1" | tr -s [:alpha:] Y )" = "--Y"                # check if first token is of form '--optionname'
                 then OPTION_KEY="$1"; OPTION_VALUE="$2"; OPTION_SHIFT=2
                      if   test -z "$OPTION_VALUE"
                      then error "Error: Option ${OPTION_KEY} requires an argument but none was provided." && return 1
                      fi
                 elif test "$( echo "$1" | tr -s [:alpha:] Y | cut -b -4 )" = "--Y="   # check if first token is of form '--optionname='
                 then OPTION_KEY="$(   echo "$1" | cut -d= -f1 )"
                      OPTION_VALUE="$( echo "$1" | cut -d= -f2 )"
                      OPTION_SHIFT=1
                      if   test -z "$OPTION_VALUE"
                      then error "Error: Option ${OPTION_KEY} requires an argument but none was provided." && return 1
                      fi
                 else error "Error: '$1' seems not to be a valid first token for a long form key value option?" && return 1
                 fi

          # If a long-form option is detected but is not valid, raise an error
            elif $STILL_PROCESSING_OPTIONS &&
                 test "${1:0:2}" = "--"
            then error "Error: Unknown option '${1%=*}' passed to $COMMAND_NAME" && return 1

          # Process key-value option in short form if valid
            elif $STILL_PROCESSING_OPTIONS &&
                 test "${1:0:1}" = "-"    &&
                 is_in "${1:0:2}" "${VALID_SHORT_KEYVAL_OPTIONS[@]}"
            then if   test ${#1} -eq 2   # Check if option key is contiguous with value or not and assign accordingly
                 then OPTION_KEY="$1"      ; OPTION_VALUE="$2"    ; OPTION_SHIFT=2
                 else OPTION_KEY="${1:0:2}"; OPTION_VALUE="${1:2}"; OPTION_SHIFT=1
                 fi

          # Process flag option in short form if valid
            elif $STILL_PROCESSING_OPTIONS &&
                 test "${1:0:1}" = "-"    &&
                 test ${#1} -eq 2         &&
                 is_in "$1" "${VALID_SHORT_FLAG_OPTIONS[@]}"
            then OPTION_KEY="$1"; OPTION_VALUE="On"; OPTION_SHIFT=1

          # If concatenated short-form flags are detected, split and reprocess
            elif $STILL_PROCESSING_OPTIONS &&
                 test "${1:0:1}" = "-"    &&
                 is_in "-${1:1:1}" "${VALID_SHORT_FLAG_OPTIONS[@]}"
            then set -- "${1:0:2}" "-${1:2}" "${@:2}"   # split joined flags
                 continue

          # If a short-form option is detected but is not valid, raise an error
            elif $STILL_PROCESSING_OPTIONS &&
                 test "${1:0:1}" = "-"    &&
                 test ${#1} -gt 1
            then error "Error: Unknown option '${1:0:2}' passed to $COMMAND_NAME" && return 1

          # All option scenarios covered; process next token as a normal argument.
            else ARGS[${#ARGS[@]}]="$1"   # i.e. append at end of ARGS array
                 shift && continue
            fi


          # If we're here it means an option has been processed
            OPTIONS["$OPTION_KEY"]="$OPTION_VALUE"
            shift $OPTION_SHIFT
      done


    # Confirm that there are is no simultaneous use of equivalent short/long
    # flag or keyval options. In other words, for any appearing short options
    # that also appear as 'paired' in the VALID_FLAG_OPTIONS or
    # VALID_KEYVAL_OPTIONS array variables, make sure their long equivalents do
    # not also appear in the OPTIONS array

      for  OPTKEY in "${!OPTIONS[@]}"
      do   if   is_in "$OPTKEY" "${VALID_SHORT_FLAG_OPTIONS[@]}"
           then for  POSSIBLE_PAIR in "${VALID_FLAG_OPTIONS[@]}"
                do   if   test "$( echo "$POSSIBLE_PAIR" | tr -cd / | wc -c )" -eq 1 && test "${POSSIBLE_PAIR%/*}" = "$OPTKEY" && is_in "${POSSIBLE_PAIR#*/}" "${!OPTIONS[@]}"
                     then error "Error: equivalent short and long flag options '${OPTKEY}' and '${POSSIBLE_PAIR#*/}' cannot be provided at the same time." && return 1
                     fi
                done
           fi
      done

      for  OPTKEY in "${!OPTIONS[@]}"
      do   if   is_in "$OPTKEY" "${VALID_SHORT_KEYVAL_OPTIONS[@]}"
           then for  POSSIBLE_PAIR in "${VALID_KEYVAL_OPTIONS[@]}"
                do   if   test "$( echo "$POSSIBLE_PAIR" | tr -cd / | wc -c )" -eq 1 && test "${POSSIBLE_PAIR%/*}" = "$OPTKEY" && is_in "${POSSIBLE_PAIR#*/}" "${!OPTIONS[@]}"
                     then error "Error: equivalent short and long key-value options '${OPTKEY}' and '${POSSIBLE_PAIR#*/}' cannot be provided at the same time." && return 1
                     fi
                done
           fi
      done


    # By this points the OPTIONS and ARGS arrays have been populated
    # and will be accessed by the parent function after this one returns.

   }


   function error () {
    # --------------------------------------------------------------------------
    # A useful, 'libstderred.so' compatible function for safely echoing error
    # messages to stderr (see: https://unix.stackexchange.com/a/164223)
    # --------------------------------------------------------------------------

      awk "BEGIN { print \"$*\" > \"/dev/stderr\" }"
   }




   function is_in () {
    # --------------------------------------------------------------------------
    # Checks if first input reoccurs in the remaining list of input arguments.
    #
    # The intended way to call this function is with an 'exploded' array
    # variable as the second argument, effectively checking if the first input
    # is a member of the array, e.g.:
    #
    #   Elements=( 1 3 5 7 9 )
    #   is_in 5 "${Elements[@]}"   # succeeds
    #   is_in 6 "${Elements[@]}"   # fails
    # --------------------------------------------------------------------------

      Element="$1" && shift
      for Arg; do test "$Element" = "$Arg" && return 0; done
      return 1
   }

   

   function warning () {
    # ------------------------------------
    # Same as `error`, but printed in blue
    # ------------------------------------

      error "${ANSI_BLUE}$*${ANSI_RESET}"
   }