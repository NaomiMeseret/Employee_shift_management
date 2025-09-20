import { networkInterfaces } from 'os';

/**
 * Get the local network IP address
 * @returns {string} The local IP address
 */
export function getLocalIP() {
  const interfaces = networkInterfaces();
  
  for (const name of Object.keys(interfaces)) {
    for (const networkInterface of interfaces[name]) {
      // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
      if (networkInterface.family === 'IPv4' && !networkInterface.internal) {
        return networkInterface.address;
      }
    }
  }
  
  return 'localhost'; // fallback
}

/**
 * Get all available network interfaces
 * @returns {Array} Array of network interface info
 */
export function getAllNetworkInterfaces() {
  const interfaces = networkInterfaces();
  const result = [];
  
  for (const name of Object.keys(interfaces)) {
    for (const networkInterface of interfaces[name]) {
      if (networkInterface.family === 'IPv4' && !networkInterface.internal) {
        result.push({
          name,
          address: networkInterface.address,
          netmask: networkInterface.netmask,
          mac: networkInterface.mac
        });
      }
    }
  }
  
  return result;
}

/**
 * Display network information for debugging
 */
export function displayNetworkInfo() {
  const localIP = getLocalIP();
  const interfaces = getAllNetworkInterfaces();
  
  console.log('\n🌐 Network Information:');
  console.log(`📍 Primary IP: ${localIP}`);
  console.log('📋 Available interfaces:');
  
  interfaces.forEach((iface, index) => {
    console.log(`   ${index + 1}. ${iface.name}: ${iface.address}`);
  });
  
  console.log('\n📱 For mobile devices, use:');
  console.log(`   http://${localIP}:3000/api`);
  console.log('\n💻 For web development, use:');
  console.log('   http://localhost:3000/api');
  console.log('\n🤖 For Android emulator, use:');
  console.log('   http://10.0.2.2:3000/api\n');
}

export default { getLocalIP, getAllNetworkInterfaces, displayNetworkInfo };
