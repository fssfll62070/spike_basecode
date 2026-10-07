################################################################################
# mission_one.py
#
# Description:
# [Describe What your mission does here]
#
# Author(s): [Your Name(s)]
# Date: [YYYY-MM-DD]
# Version: 1.0
# owen is going to code
# Dependencies:
# - robot
# - pybricks.tools
# Demo GitHub
################################################################################
from robot import robot
from pybricks.tools import wait, StopWatch

def mission_one(r: robot):
    print("Running Mission 1")
    # Your code goes here...
    # Sample Code: Run attachment motors and drive motors
    r.lam.run_time(1000,1000)
    r.lam.run_time(-1000,1000)
    r.ram.run_time(400,1000)
    r.ram.run_time(-400,1000)
    r.ldm.run_time(1000,1000)
    r.ldm.run_time(-1000,1000)
    r.rdm.run_time(400,1000)
    r.rdm.run_time(-400,1000)

    r.robot.straight(425)
    r.robot.turn(-70)
    r.robot.straight(-150)
    r.robot.turn(-25)
    r.robot.straight(375)
    r.robot.turn(60)
    r.robot.straight(-75)
    r.robot.straight(30)
################################
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
