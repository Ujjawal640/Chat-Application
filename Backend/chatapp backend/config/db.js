const mongoose=require('mongoose')

const connectdb=async()=>{
        const con=await mongoose.connect("mongodb://localhost:27017",{
            useNewUrlParser:true,
            useUnifiedTopology:true,
        });
}

module.exports=connectdb;