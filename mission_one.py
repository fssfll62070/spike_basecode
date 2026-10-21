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
    r.robot.straight(440)
    r.robot.turn(-90)
    r.robot.straight(-150)
    r.robot.turn(80)
    r.robot.straight(130)
    r.robot.turn(45)
    r.ram.run_time(-300,1000)
    r.robot.straight(80)
    r.ram.run_time(800,1000)
    r.ram.run_time(-740,1000)
    r.robot.straight(-180)
    r.robot.turn(-60)
    r.robot.straight(-380)

################################
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
