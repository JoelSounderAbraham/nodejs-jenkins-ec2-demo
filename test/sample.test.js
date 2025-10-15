const http = require('http');
const childProcess = require('child_process');

let server;
beforeAll(done => {
  server = childProcess.spawn('node', ['src/index.js']);
  setTimeout(done, 800);
});
afterAll(() => {
  if (server && !server.killed) server.kill();
});

test('root endpoint returns hello', done => {
  http.get('http://localhost:3000/', res => {
    expect(res.statusCode).toBe(200);
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      expect(data).toMatch(/nodejs-jenkins-ec2-demo/);
      done();
    });
  });
});

test('health endpoint returns OK', done => {
  http.get('http://localhost:3000/health', res => {
    expect(res.statusCode).toBe(200);
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      expect(data).toBe('OK');
      done();
    });
  });
});
