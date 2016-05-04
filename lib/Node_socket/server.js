var redis = require("redis").createClient();
redis.subscribe("sent");

var express = require('express');
var app = express();

var fs = require('fs');

var options = {
  key: fs.readFileSync('/etc/ssl/adae.key'),
  cert: fs.readFileSync('/etc/ssl/cert_chain.crt'),
  NPNProtocols: ['http/2.0', 'spdy', 'http/1.1', 'http/1.0']
};

var server = require('https').createServer(options, app);
var io = require('socket.io')(server);

io.on("connection", function(socket){
  console.log("connected socket")
  socket.on("disconnect", function(){
    console.log("client disconnected");
    socket.disconnect();
  });
});

redis.on("message", function(channel, message){
  var info = JSON.parse(message);
  io.sockets.emit(channel, info);
  console.log(info);
});

server.listen(40091, function(){
    console.log('Express server listening on port 40091');
});
