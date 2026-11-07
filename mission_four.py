################################################################################
# mission_four.py
#
# Description:
# [Describe What your mission does here]
#
# Owen(s): [Your Name(s)]
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

def mission_four(r: robot):
    print("Running Mission 4")
    # Your code goes here...
    #owenini plescanini im cheses up down chese pu nwod esech
    r.robot.straight(650)
    r.robot.turn(60)
    r.lam.run_time(1000,500)
    r.lam.run_time(-2000,500)
    r.lam.run_time(2000,500)
    r.lam.run_time(-2000,500)
    r.robot.turn(-60)
    r.robot.straight(-650)
################################
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
