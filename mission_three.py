################################################################################
# mission_three.py
#
# Description:
# [Describe What your mission does here]
#
# Author(s): [pierce]
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

def mission_three(r: robot):
    print("Running Mission 3")
    # Your code goes here...
    # Mission 3 is Pierce's Code
    # Sample Code: Test running the attachment motor until stalled
    r.robot.straight(400)
    r.ram.run_time(-1000,400)
    r.robot.straight(-120)
    r.ram.run_time(1000,400)
    r.robot.straight(12)
    r.robot.straight(-400)
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
