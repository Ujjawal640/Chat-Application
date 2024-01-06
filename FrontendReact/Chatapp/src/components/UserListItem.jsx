import { Avatar, Box, Text } from '@chakra-ui/react'
import React from 'react'

const UserListItem = ({user,handleFunction}) => {
  return (
    <Box
    onClick={handleFunction}
    display="flex"
    width="100%"
    px={2}
    py={3}
    alignItems="center"
    color="black"
    borderRadius="lg"
    >
        <Avatar name={user.name} size='md' src={user.pic} mr={3}/>
        <Box>
            <Text fontSize="md">{user.name}</Text>
            <Text fontSize="xs">{user.email}</Text>
        </Box>
      
    </Box>
  )
}

export default UserListItem
