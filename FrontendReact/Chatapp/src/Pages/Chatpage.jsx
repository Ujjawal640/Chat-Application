import { useEffect, useState } from "react";
import { ChatState } from "../Context/ChatProvider";
import Sidedrawaer from "../components/miscellaneous/Sidedrawaer";
import { Box } from "@chakra-ui/react";
import MyChats from "../components/MyChats";
import Chatbox from "../components/Chatbox";

const Chatpage = () => {
  const [fetchAgain, setFetchAgain] = useState(false);

    const user = JSON.parse(localStorage.getItem("userInfo"));
   



  return (
   <div style={{width:"100%", height: "100%"}}>
    
    
    <Box 
    display="flex"
    justifyContent="space-evenly"
    w="100%"
    h="100%"
    p="10px"
    >
      <div style={{width:"100%"}}> {user && <MyChats fetchAgain={fetchAgain} />}</div>
      <div style={{width:"100%"}}>   {user && <Chatbox fetchAgain={fetchAgain} setFetchAgain={setFetchAgain}  />}</div>
 
  

    </Box>
   </div>
  );
};

export default Chatpage;
