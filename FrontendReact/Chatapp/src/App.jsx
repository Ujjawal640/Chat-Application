import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Homepage from "./Pages/Homepage";
import Chatpage from "./Pages/Chatpage";
import { ChakraProvider } from "@chakra-ui/react";
import ChatProvider from "./Context/ChatProvider";
import './App.css';

export default function App() {
  return (
    <Router>
      <ChatProvider>
        <ChakraProvider>
          <Routes>
            <Route path="/" element={<Homepage />} />
            <Route path="/chats" element={<Chatpage />} />
          </Routes>
        </ChakraProvider>
      </ChatProvider>
    </Router>
  );
}
