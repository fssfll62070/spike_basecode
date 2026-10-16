################################################################################
# mission_five.py
#
# Description:
# [Describe What your mission does here]
#
# Author(s): [Your Name(s)]
# Date: [YYYY-MM-DD]
# Version: 1.0
#
# Dependencies:
# - robot
# - pybricks.tools
#
################################################################################
from robot import robot
from pybricks.tools import wait, StopWatch

def mission_five(r: robot):
    print("Running Mission 5")
    # Your code goes here...
    r.robot.straight(520)
#notes = ["E5/5.", "G6/6", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "D4/16", "A6/1"
#]


#r.hub.speaker.play_notes(notes,360)
################################
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
