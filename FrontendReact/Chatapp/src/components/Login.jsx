import React, { useState } from 'react'
import { VStack } from "@chakra-ui/layout";
import { Button } from "@chakra-ui/button";
import { FormControl, FormLabel } from "@chakra-ui/form-control";
import { Input, InputGroup, InputRightElement } from "@chakra-ui/input";
import { useNavigate } from "react-router-dom";
import { useToast } from "@chakra-ui/toast";
import axios from 'axios';
import { ChatState } from "../Context/ChatProvider";




const Login = () => {
  
  const [show, setshow] = useState(false);

  const [Email, setEmail] = useState();
  const [Password, setPassword] = useState();

  const handleclick =()=>{
    setshow(!show);
  }

  const toast = useToast();

  const [loading, setLoading] = useState(false);

  const history = useNavigate();
  const { setuser } = ChatState();

  const submitHandler = async () => {
    setLoading(true);
    if (!Email || !Password) {
      toast({
        title: "Please Fill all the Feilds",
        status: "warning",
        duration: 5000,
        isClosable: true,
        position: "bottom",
      });
      setLoading(false);
      return;
    }

    try {
      const config = {
        headers: {
          "Content-type": "application/json",
        },
      };

      const { data } = await axios.post(
        "http://localhost:5174/api/user/login",
        {
        email: Email,
        password: Password
        },
        config
      );

      toast({
        title: "Login Successful",
        status: "success",
        duration: 5000,
        isClosable: true,
        position: "bottom",
      });
      setuser(data);
      localStorage.setItem("userInfo", JSON.stringify(data));
      setLoading(false);
      history("/chats");
    } catch (error) {
      toast({
        title: "Error Occured!",
        description: error.response.data.message,
        status: "error",
        duration: 5000,
        isClosable: true,
        position: "bottom",
      });
      setLoading(false);
    }
  };


  return (
    <VStack spacing="10px">
    <FormControl id="email" isRequired>
      <FormLabel>Email Address</FormLabel>
      <Input
        
        type="email"
        placeholder="Enter Your Email Address"
        onChange={(e) => {setEmail(e.target.value)}}
      />
    </FormControl>
    <FormControl id="password" isRequired>
      <FormLabel>Password</FormLabel>
      <InputGroup size="md">
        <Input
          type={show ? "Text" : "Password"}
          onChange={(e) =>{setPassword(e.target.value)} }
         
          placeholder="Enter password"
        />
        <InputRightElement width="4.5rem">
          <Button h="1.75rem" size="sm" onClick={handleclick}>
         {show ? "Hide" : "Show"}
          </Button>
        </InputRightElement>
      </InputGroup>
    </FormControl>
    <Button
      colorScheme="blue"
      width="100%"
      style={{ marginTop: 15 }}
      onClick={submitHandler}
      isLoading={loading}
  
    >
      Login
    </Button>
   
  </VStack>
);
}

export default Login
