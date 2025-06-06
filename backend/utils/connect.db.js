import mongoose from "mongoose";

const connectDB = async () => {
  try{
    await mongoose.connect(process.env.MONGO_URI ,{
      connectTimeoutMS: 30000, // extend timeout
  socketTimeoutMS: 45000
    });
  }catch(err){
    console.log(err)
  } 
  console.log("MongoDB connected");
}

export default connectDB;