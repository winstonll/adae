//var app = require('https').createServer().listen(5001);

var redis = require("redis").createClient();
redis.subscribe("sent");

var express = require('https');
var app = require('https').createServer().listen(5001); 

var port = process.env.PORT || 5001;
var fs = require('fs');

var options = {
  key: fs.readFileSync('/etc/ssl/adae.key'),
  cert: fs.readFileSync('/etc/ssl/cert_chain.crt')
};
var server = require('https').createServer(options, app);
var io = require('socket.io')(server);




//var io = require("socket.io").listen(app);

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
