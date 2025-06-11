import mongoose from "mongoose";
import dns from 'dns';

const connectDB = async () => {
  try {
    // Configure DNS to use Google's DNS servers
    dns.setServers(['8.8.8.8', '8.8.4.4']);

    const options = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      family: 4,
      maxPoolSize: 10,
      minPoolSize: 5,
      retryWrites: true,
      retryReads: true
    };

    const conn = await mongoose.connect(process.env.MONGO_URI, options);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (err) {
    console.error('MongoDB connection error:', err);
    // Don't exit immediately, try to reconnect
    setTimeout(connectDB, 5000);
  }
}

export default connectDB;