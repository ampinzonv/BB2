#!/usr/bin/env bash
source $BIOBASH_HOME/lib/shml/shml.sh
source $BIOBASH_HOME/lib/bb_native/file.sh


# @file Feedback
# @brief Functions to handle user feedback and message prompting
# @description Displays a message and file name from where message is generated.
#
# @example
# 	feedback::sayfrom "I am a warning" "warn"
# 	feedback::sayfrom "I am an error" "error"
# 	feedback::sayfrom "I am just a message" "msg"
# 	feedback::sayfrom "I am a succesful messahe" "success"
#
# @arg $1 What you want to say
# @arg $2 Type of message (warn, error, msg or success).
feedback::sayfrom()
{

if [ $2 = "error" ]; then
  color="red"
  preset="[Error] "
elif [ $2 = "warn" ]; then 
  color="lightyellow" 
  preset="[Warn] "
elif [ $2 = "msg" ]; then 
  color="blue"
elif [ $2 = "success" ]; then 
  color="green"
 else
   color="darkgray"
fi

echo $(fgcolor lightblue "Message from: $0") $(fgcolor end)
echo $(fgcolor $color  "$preset $1") $(fgcolor end)

}


# @description Displays a message.
#
# @example
# 	feedback::say "I am a warning" "warn"
# 	feedback::say "I am an error" "error"
# 	feedback::say "I am just a message" "msg"
# 	feedback::say "I am a succesful messahe" "success"
#
# @arg $1 What you want to say
# @arg $2 Type of message (warn, error, msg or success).
feedback::say()
{

if [ $2 = "error" ]; then
  color="magenta"
elif [ $2 = "warn" ]; then 
  color="lightyellow" 
elif [ $2 = "msg" ]; then 
  color="blue"
elif [ $2 = "success" ]; then 
  color="green"
 else
   color="gray"
fi

echo $(fgcolor $color "$1") $(fgcolor end)

}


# @description Displays a help message.
#
# @example
# 	feedback::help $Description $Message
#
# @arg $1 Script description.
# @arg $2 Script usage.
feedback::help()
{

  script=$(file::basename $0)
  echo ""
  echo "$(indent) $(color red)>$(color end) $(attribute bold "$script.")$(attribute end) "
  echo "$(indent) $(a dim "$1") $(a end)"
  echo "$(indent) $(a dim "---") $(a end)"
  echo ""
  echo "$(indent) Usage:"
  echo "$(indent) $2"
  echo ""
  
}
