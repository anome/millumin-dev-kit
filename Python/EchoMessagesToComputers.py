import OSC
import sys, time, random, threading

# CONFIGURATION
machinesIP = ["127.0.0.1", "192.168.0.21", "192.168.0.31", "192.168.0.41"]
messagesToEcho = ["/millumin/action/playOrStop/", "/millumin/layer/opacity/1"]
milluminListenPort = 5000
senderPort = 7000
printMessage = 1







# TO SEND OSC MESSAGES TO MACHINES
oscClients = []
for i in range(len(machinesIP)) :
    client = OSC.OSCClient()
    client.connect(  (machinesIP[i],milluminListenPort)  )
    oscClients.append(client)

# TO RECEIVE OSC MESSAGES (from TouchOSC for example)
oscServer = OSC.OSCServer(  ('0.0.0.0',senderPort)  )



def message_handler(addr, tags, stuff, source):
    # ECHO MESSAGE TO MACHINES
    msg = OSC.OSCMessage()
    msg.setAddress(addr)
    msg.append(stuff)
    for i in range(len(machinesIP)) : 
        oscClients[i].send(msg)
    # PRINT MESSAGE
    if printMessage :    
        print "---"
        print "received new osc msg from %s" % OSC.getUrlStr(source)
        print "with addr : %s" % addr
        print "typetags %s" % tags
        print "data %s" % stuff
        print "---"

for i in range(len(messagesToEcho)) :
	oscServer.addMsgHandler(messagesToEcho[i], message_handler)

st = threading.Thread( target = oscServer.serve_forever )
st.start()










# WAIT UNTIL CMD+C
try:
    print "Press CMD+C to exit"
    while True:
        time.sleep(0.1)
except KeyboardInterrupt:
    oscServer.close()
    sys.exit(0)