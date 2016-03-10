import OSC
import time, random, threading




# TO SEND OSC MESSAGES
oscClient = OSC.OSCClient()
oscClient.connect(  ('127.0.0.1',5000)  )




# TO RECEIVE OSC MESSAGES
oscServer = OSC.OSCServer(  ('127.0.0.1',5001)  )

def printing_handler(addr, tags, stuff, source):
    print "---"
    print "received new osc msg from %s" % OSC.getUrlStr(source)
    print "with addr : %s" % addr
    print "typetags %s" % tags
    print "data %s" % stuff
    print "---"

oscServer.addMsgHandler("/millumin/selectedLayer/opacity", printing_handler)
oscServer.addMsgHandler("/millumin/index:1/opacity", printing_handler)

st = threading.Thread( target = oscServer.serve_forever )
st.start()








# TEST 1 : SENDING OSC BUNDLE
bundle = OSC.OSCBundle()
msg = OSC.OSCMessage()
msg.setAddress("/millumin/selectedLayer/opacity")
msg.append(80)
bundle.append(msg)
bundle.append( {'addr':"/millumin/index:1/opacity", 'args':[80]} )
oscClient.send(bundle)






# TEST 2 : SENDING AND RECEIVING OSC MESSAGES
try :
	seed = random.Random()
	while 1 :
		msg = OSC.OSCMessage()
		msg.setAddress("/millumin/selectedLayer/opacity")
		n = seed.randint(0, 100)
		msg.append(n)
		oscClient.send(msg)
		time.sleep(1)
except KeyboardInterrupt :
	print "\nClosing OSCClient and OSCServer"
	oscClient.close()
	oscServer.close()
	st.join()
	print "Done"
        
