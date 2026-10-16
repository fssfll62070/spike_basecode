################################################################################
# mission_seven.py
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

def mission_seven(r: robot):
    print("Running Mission 7")
    # Your code goes here...Hailey's code
    r.robot.arc(100,43)
    r.robot.turn(-30)
    r.lam.run_angle(50,30)
    r.robot.straight(30)
################################
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
