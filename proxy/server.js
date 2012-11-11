var net = require('net');
var path = require('path');

var noop = function() {};
var proxy = net.createServer();

proxy.on('connection', function(connection) {
	var buffer = new Buffer(65536);
	var offset = 0;

	connection.setTimeout(2*60*1000, function() {
		connection.destroy();
	});
	connection.on('data', function ondata(data) {
		if (data.length + offset > buffer.length) return;

		data.copy(buffer, offset);
		offset += data.length;

		var host = (buffer.toString('ascii', 0, offset).match(/\r\nhost: ([^\r]+)\r\n/i) || [])[1];

		if (!host) return;

		host = path.normalize(host.split(':')[0].replace(/^www\./, ''));
		connection.removeListener('data', ondata);

		var guest = net.connect('/tmp/'+host+'.git.sock');

		connection.setTimeout(0); // our unix socket should take care of timeouts now (TODO: check up on this)
		guest.write(buffer.slice(0, offset));
		guest.on('error', noop);

		connection.pipe(guest).pipe(connection);
	});
	connection.on('error', noop);
});

proxy.listen(80);
