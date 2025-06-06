import express from 'express';
import dotenv from "dotenv";
import connectDB from "./utils/connect.db.js";

const app = express()
dotenv.config();
if (process.env.NODE_ENV !== "test") {
      
        const port = process.env.PORT || 3000;
        app.listen(port, connectDB());
  
  }
