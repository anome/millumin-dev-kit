import OSC
import time, os

# PREPARE TO SEND MESSAGES TO MILLUMIN
# BE SURE OSC IS ACTIVATED IN MILLUMIN : from the menubar, click on 'Devices' then 'Setup OSC...'
oscClient = OSC.OSCClient()
oscClient.connect(  ('127.0.0.1',5000)  )



# RUN MILLUMIN
os.system('open /Applications/Millumin.app');
time.sleep(5)

# OPEN PROJECT
msg = OSC.OSCMessage("/millumin/action/openProject")
msg.append("/Users/username/Desktop/project.millu")
oscClient.send(msg)
time.sleep(5)

# GO TO FULLSCREEN
msg = OSC.OSCMessage("/millumin/action/fullscreen")
msg.append(1)
oscClient.send(msg)