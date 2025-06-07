import express from "express";
import dotenv from "dotenv";
import connectDB from "./utils/connect.db.js";
import employeeRoutes from "./routes/employees.route.js";
import cors from 'cors';


dotenv.config();
const app = express();

// Middleware to log all incoming API requests
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url} ${res.stats} ${200 <= res.statusCode < 300  ? '✅' : '❌'}}`);
    next();
  });
  
  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));
  
  app.use("/api", employeeRoutes);

  

  if (process.env.NODE_ENV !== "test") {
      
        const port = process.env.PORT || 3000;
        app.listen(port, connectDB());
  
  }
  
  export default app;