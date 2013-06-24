import com.illposed.osc.*;
import java.net.InetAddress;

public class OSCTest
{
	
	protected static OSCPortOut sender;
	protected static OSCPortIn receiver;

	public static void main(String[] args) throws Exception
	{	
		// SEND OSC MESSAGE
		try
		{
			InetAddress address = InetAddress.getLocalHost(); 
			sender = new OSCPortOut(address, 5000);
			Object arguments[] = new Object[1];
			arguments[0] = new Integer(80);
			OSCMessage msg = new OSCMessage("/millumin/layer/opacity/0", arguments);
			sender.send(msg);
		}
		catch (Exception e)
		{
			throw new Exception("OSC message cannot be sent.");
		}
		// RECEIVE OSC MESSAGES
		receiver = new OSCPortIn(5001);
		OSCListener listener = new OSCListener()
		{
			public void acceptMessage(java.util.Date time, OSCMessage message)
			{
				Object[] arguments = message.getArguments();
				if( 0 < arguments.length )
				{
					float value = Float.parseFloat( arguments[0].toString() );
					System.out.println("Message received with argument : "+value);
					if( value == 0 || value == 100 )
					{
						receiver.stopListening();
					}
				}
			}
		};
		receiver.addListener("/millumin/layer/opacity/0", listener);
		receiver.startListening();
	}
	
	
}
