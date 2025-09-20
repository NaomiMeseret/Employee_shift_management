import dotenv from 'dotenv';

dotenv.config();

export const getApiConfig = () => {
  const host = process.env.HOST || 'localhost';
  const port = process.env.PORT || 3000;
  
  return {
    host,
    port,
    baseUrl: `http://${host}:${port}/api`,
    // For different environments
    getPublicUrl: () => {
      if (process.env.NODE_ENV === 'production') {
        return process.env.API_BASE_URL || `https://your-domain.com/api`;
      }
      
      // For development, detect if we need to use network IP
      if (host === '0.0.0.0') {
        // Return the actual network IP for mobile device access
        return `http://192.168.1.6:${port}/api`;
      }
      
      return `http://${host}:${port}/api`;
    }
  };
};

export default getApiConfig;
