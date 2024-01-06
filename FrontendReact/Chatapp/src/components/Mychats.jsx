import React, { useEffect, useState } from 'react'
import Sidedrawaer from './miscellaneous/Sidedrawaer'
import { ChatState } from '../Context/ChatProvider';
import { Box, Stack, Text, useToast } from '@chakra-ui/react';
import axios from 'axios';
import { getSender } from '../config/ChatLogics';
import Loading from './miscellaneous/Loading';

const MyChats = ({fetchAgain}) => {
  const [loggeduser, setloggeduser] = useState(JSON.parse(localStorage.getItem("userInfo")));

  const { user,setuser,selectedchat, setselectedchat,chats, setchats} = ChatState();

  const toast =useToast();

  const fetchchats=async()=>{

    try {

      const config={
        headers:{
          Authorization:`Bearer ${loggeduser.token}`
        }
      };

      const {data}=await axios.get("http://localhost:5174/api/chat",config);
      setchats(data);
      //console.log(data);
      
    } catch (error) {
      console.log(error);
      
    }

    

  }

  useEffect(() => {
    setloggeduser(JSON.parse(localStorage.getItem("userInfo")));

    fetchchats();

    console.log(6);
  
  
    
  },[fetchAgain] )


  const changechatcolor=(chat)=>{
    setselectedchat(chat)

  }
  

  return (
    <div style={{height:"100%"}}>
       <Sidedrawaer/>
       <Box
       
       w="100%"
       
       
       alignItems="center"
       >
      <Box
        py={1}
        px={3}
        fontSize={{ base: "28px", md: "30px" }}
        fontFamily="Work sans"
        display="flex"
        w="100%"
        
        justifyContent="space-between"
      >
        My Chats
        
      </Box>
      <Box
        display="flex"
        flexDir="column"
        p={3}
        bg="#F8F8F8"
        w="100%"
        h="100%"
        borderRadius="lg"
        overflowY="hidden"
      >
        {chats ? (
          <Stack overflowY="scroll">
            {chats.map((chat) => (
              <Box
                onClick={() => changechatcolor(chat)}
                cursor="pointer"
                bg={selectedchat === chat ? "#38B2AC" : "#E8E8E8"}
                color={selectedchat === chat ? "white" : "black"}
                px={3}
                py={2}
                borderRadius="lg"
                key={chat._id}
              >
                <Text>
                  {!chat.isGroupChat
                    ? getSender(loggeduser, chat.users)
                    : chat.chatName}
                </Text>

                
              </Box>
            ))}
          </Stack>
        ) : (
          <h1>loading</h1>
        )}
      </Box>
      </Box>
    </div>
  )
}

export default MyChats
