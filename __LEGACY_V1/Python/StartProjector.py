import socket, sys


client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(  (sys.argv[1],3002)  )
data = sys.argv[2]
client_socket.send(data)
client_socket.close()