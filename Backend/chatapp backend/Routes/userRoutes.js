const express=require("express");
const { loginuser, singup ,allusers} = require("../Conotroller/userController");
const { protect } = require("../Middleware/authMiddleware");
const router=express.Router();

router.post("/login", loginuser);
router.route('/').post(singup).get(protect,allusers);

  
module.exports=router;