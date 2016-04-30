var http = require("http");

var redis = require("redis").createClient();
redis.subscribe("sent");

var io = require("socket.io").listen(process.env.PORT || 5001);

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