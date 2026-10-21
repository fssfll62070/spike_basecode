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
    r.robot.straight(455)
    r.ram.run_angle(90,-90)
    r.robot.straight(-455)
    r.ram.run_angle(90,90)
    #notes = [ "E5/4.", "G6/4", "D4/16.", "R/4", "G4/16.", "R/4", "D3/16.", "R/4", "G3/16.", "R/4", "D4/16.", "R/4", "G4/16.", "R/4", "D3/16.", "R/4", "G3/16.", "R/4", "D4/16.", "R/4",  "G4/16.", "R/4", "D3/16.", "R/4", "G3/16.", "R/1" ]
    #r.hub.speaker.play_notes(notes,200)
    #notes= [
    # "E4/4_", "G4/4", "E4/4", "E4/4", "A4/4", "E4/4", "D4/4",
    # "E4/4_", "B4/4", "E4/4", "E4/4", "C4/4", "B3/4", "G3/4",
    # "E4/4", "B3/4", "E4/4", "E4/4", "D4/4", "D3/4", "B3/4", "F#3/4", "E3/2."
    # ]
    # r.hub.speaker.play_notes(notes,360)

################################
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
