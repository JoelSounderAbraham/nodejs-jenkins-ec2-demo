const http = require('http');

const port = process.env.PORT || 3000;
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200);
    res.end('OK');
  } else {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello from nodejs-jenkins-ec2-demo!');
  }
});

server.listen(port, () => {
  console.log(`Server running at http://0.0.0.0:${port}/`);
});
