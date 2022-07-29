(

var addrs = Dictionary.new;


n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
OSCdef(\id, {|msg, time, addr, recvPort|

	addr.port = msg[1];
	addrs.put(addr.ip, addr);

	addrs.do({|address|
		address.sendMsg('/ip', address.ip, address.port);
	});

	"ip".postln;
}, '/ip'); // def style

)
