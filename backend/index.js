import express from "express";
import dotenv from "dotenv";
import connectDB from "./utils/connect.db.js";
import employeeRoutes from "./routes/employees.route.js";
import cors from 'cors';
import { getLocalIP, displayNetworkInfo } from './utils/network.js';


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
        const host = process.env.HOST || '0.0.0.0';
        const localIP = getLocalIP();
        
        app.listen(port, host, () => {
          console.log(`🚀 Server running on http://${host}:${port}`);
          console.log(`📡 Local API: http://localhost:${port}/api`);
          console.log(`📱 Network API: http://${localIP}:${port}/api`);
          
          // Display detailed network information
          displayNetworkInfo();
          
          connectDB();
        });
  }
  
  export default app;