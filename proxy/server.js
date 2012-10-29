var net = require('net');
var path = require('path');

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

		guest.write(buffer.slice(0, offset));
		connection.pipe(guest).pipe(connection);

		guest.on('error', function() {
			guest.destroy();
			connection.destroy();
		});
	});
	connection.on('error', function() {
		connection.destroy();
	});
});

proxy.listen(80);
