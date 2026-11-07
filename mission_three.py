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

#from time import time

from robot import robot
from pybricks.tools import wait, StopWatch

def mission_three(r: robot):
    print("Running Mission 3")
    # Your code goes here...
    # Mission 3 is Pierce's Code
    # Sample Code: Test running the attachment motor until stalled

################################

<<<<<<< HEAD
    r.robot.straight(400)
    r.ram.run_time(-850,200, wait=False)
    r.ram.run_time(-850,400)
    r.robot.straight(-400)
    r.ram.run_time(850,400, wait=False)
    r.ram.run_time(580,400)
    r.robot.straight(370)
    r.ram.run_time(-580,400, wait=False)
    r.ram.run_time(-580,400)
||||||| 0adc5bb
    r.robot.straight(405)
    r.ram.run_angle(-850,75)
    r.robot.straight(-405)
    r.ram.run_angle(850,75)
    r.robot.straight(365)
    r.ram.run_angle(-580,75)
=======
    r.robot.straight(385)
    r.ram.run_angle(-850,75)
    r.robot.straight(-110)
    r.ram.run_angle(810,75)
    r.robot.straight(103)
    r.ram.run_angle(-850,75)
>>>>>>> 995b6b34256b383af64a8c35058a37995d25ad61
    r.robot.straight(-415)

# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()

