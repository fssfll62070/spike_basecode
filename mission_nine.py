################################################################################
# mission_nine.py
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

def mission_nine(r: robot):
     print("Running Mission 9")
<<<<<<< HEAD
    # Your code

################################
||||||| 5145d40
    # Your code goes here...


################################
=======
    # Your code goes here...
     r.robot.straight(700)
     r.robot.turn(15)
     r.robot.straight(-700)
     r.robot.turn(-54)
     r.ram.run_angle(90,-90)
     r.robot.straight(350)
     r.ram.run_angle(-90,-90)
>>>>>>> 1e26de69139ed5fe575b861d637c4594ecc74d40
# KEEP THIS AT THE END OF THE FILE
# This redirects to running main.
################################
if __name__ == "__main__":
    from main import main
    main()
