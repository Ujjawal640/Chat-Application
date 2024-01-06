const express=require('express');
const connectdb = require('./config/db');
const messageRoutes=require('./Routes/messageRoutes');
const chatRoutes=require('./Routes/chatRoutes');
const userRoutes=require('./Routes/userRoutes');
require('dotenv').config();
const app=express();
const cors = require('cors');


const PORT=process.env.PORT;


connectdb();

app.use(express.json());//to accept json data for api testing
app.use(cors());

app.use(cors({
    origin: 'http://localhost:5173', // Specify the allowed origin
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE', // Specify allowed HTTP methods
    allowedHeaders: 'Content-Type,Authorization', // Specify allowed headers
  }));

app.use('/api/user',userRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/message", messageRoutes);



const server = app.listen(
  PORT,
  console.log(`Server running on PORT ${PORT}...`)
);

const io = require("socket.io")(server, {
  pingTimeout: 60000,
  cors: {
    origin: "http://localhost:5173",
    // credentials: true,
  },
});

io.on("connection", (socket) => {
  console.log("Connected to socket.io");
  socket.on("setup", (userData) => {
    socket.join(userData._id);
    socket.emit("connected");
  });

  socket.on("join chat", (room) => {
    socket.join(room);
    console.log("User Joined Room: " + room);
  });
  socket.on("typing", (room) => socket.in(room).emit("typing"));
  socket.on("stop typing", (room) => socket.in(room).emit("stop typing"));

  socket.on("new message", (newMessageRecieved) => {
    var chat = newMessageRecieved.chat;

    if (!chat.users) return console.log("chat.users not defined");

    chat.users.forEach((user) => {
      if (user._id == newMessageRecieved.sender._id) return;

      socket.in(user._id).emit("message recieved", newMessageRecieved);
    });
  });

  socket.off("setup", () => {
    console.log("USER DISCONNECTED");
    socket.leave(userData._id);
  });
});