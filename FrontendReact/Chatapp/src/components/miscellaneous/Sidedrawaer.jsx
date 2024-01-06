import { AddIcon, ChatIcon, ChevronDownIcon, EditIcon, ExternalLinkIcon, HamburgerIcon, RepeatIcon, SearchIcon, SmallAddIcon, ViewIcon } from '@chakra-ui/icons'
import { Avatar, Box, Button, IconButton, Input, Menu, MenuButton, MenuItem, MenuList, Text, Tooltip, useDisclosure, useToast } from '@chakra-ui/react'
import React, { useEffect, useState } from 'react'
import { ChatState } from "../../Context/ChatProvider";
import { useNavigate } from 'react-router-dom';
import {
    Drawer,
    DrawerBody,
    DrawerFooter,
    DrawerHeader,
    DrawerOverlay,
    DrawerContent,
    DrawerCloseButton,
  } from '@chakra-ui/react'
import axios from 'axios';
import Loading from './Loading';
import UserListItem from '../UserListItem';


const Sidedrawaer = () => {
  const {  setselectedchat,chats, setchats } = ChatState();


    const [search, setsearch] = useState("");
    const [searchresult, setsearchresult] = useState([]);
    const [loading, setloading] = useState(false);
    const [loadingChat, setloadingChat] = useState();

    const user = JSON.parse(localStorage.getItem("userInfo"));
    
    const navigate=useNavigate();

    const { isOpen, onOpen, onClose } = useDisclosure();
    const btnRef = React.useRef();
    
    const logoutuser=()=>{
        localStorage.removeItem("userInfo");
        navigate('/');

    }

    const toast=useToast();

    
    const handlesearch=async()=>{

      if(!search){
        toast({
          title: "Please Enter Something To Search",
          status: "warning",
          duration: 5000,
          isClosable: true,
          position: "top",
        });

      }
      setloading(true);
      try {
        const config={
          headers:{
            Authorization:`Bearer ${user.token}`
          }
        };

        const {data}= await axios.get(`http://localhost:5174/api/user/?search=${search}`,config);
        
        setsearchresult(data);
        setloading(false);


      } catch (error) {
        
      }


    }


    const accesschat=async(userId)=>{
      try {
        console.log(userId);
        setloadingChat(true);
        const config={
          headers:{
            "Content-type":"application/json",
            Authorization:`Bearer ${user.token}`
          }
        };
        const {data}= await axios.post("http://localhost:5174/api/chat",{userId},config);

        if (!chats.find((c) => c._id === data._id)) setchats([data, ...chats]);
      

        setselectedchat(data);
        setloadingChat(false);
        onClose();
      } catch (error) {
        
      }

    };

 
   // console.log(searchresult);
  return (
    <>

      <Box
      display="flex"
      justifyContent="space-between"
      w="100%"
      p="6px"
      >
        
        <Text w="100%">Chat App</Text>
        

        <Box  display="flex"
      w="100%"
      justifyContent="flex-end"
      
      >


      <Tooltip label="New Chat" aria-label='A tooltip' >
      
      <Button colorScheme='teal' variant='ghost'ref={btnRef} onClick={onOpen} >
      <SmallAddIcon /><ChatIcon/>   
       </Button>
       
       </Tooltip>


    

    


<Menu placement='bottom-end'>
        
 <MenuButton as={Button} rightIcon={<ChevronDownIcon/>}>
 <Avatar name={user.name} size='sm' src={user.pic} />
 </MenuButton>

  <MenuList>

    <MenuItem icon={<AddIcon />}>
      Create New Group
    </MenuItem>
    <MenuItem icon={<ViewIcon/>} >
      My Profile
    </MenuItem>
    <MenuItem icon={<ExternalLinkIcon />} onClick={logoutuser}>
      Logout
    </MenuItem>
    
  </MenuList>

</Menu>



<Drawer
        isOpen={isOpen}
        placement='left'
        onClose={onClose}
        finalFocusRef={btnRef}
      >
        <DrawerOverlay />
        <DrawerContent>
          <DrawerCloseButton />
          <DrawerHeader>New Chat</DrawerHeader>

          <DrawerBody>
            <Box display="flex" justifyContent="space-between" mb={2}>

            <Input placeholder='Search By Name or Email' value={search} onChange={(e)=>{setsearch(e.target.value)}} />

            <Button variant='outline' mx={2} onClick={handlesearch}>
              Search
            </Button>

            </Box>

            {loading?
            (<Loading/>)
            :
            ( searchresult?.map(user=>( <UserListItem key={user._id} user={user} handleFunction={()=>accesschat(user._id)} />)))
            }

          </DrawerBody>

          
        </DrawerContent>
      </Drawer>
      </Box>



      </Box>
    </>
  )
}

export default Sidedrawaer
