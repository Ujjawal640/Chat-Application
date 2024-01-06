import { createContext, useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";



const ChatContext =createContext();

const ChatProvider=({children})=>{
    const [user, setuser] = useState();
    const [selectedchat, setselectedchat] = useState();
    const [chats, setchats] = useState([]);
    const [notification, setNotification] = useState([]);

    const navigate=useNavigate();
    useEffect(() => {
      const userInfo=JSON.parse(localStorage.getItem("userInfo"));

      if(!userInfo){
        navigate("/");
      }
    }, [navigate]);
    

    return <ChatContext.Provider value={{user,setuser,selectedchat, setselectedchat,chats, setchats,notification, setNotification}}>{children}</ChatContext.Provider>
};


export const ChatState =()=> {
    return useContext(ChatContext);
};


export default ChatProvider;