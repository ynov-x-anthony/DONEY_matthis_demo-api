const http = require('http');
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
    if (req.method === 'GET' && req.url === '/health') {
        res.writeHead(200); res.end('{"status":"UP"}');
    } else if (req.method === 'POST' && req.url === '/notify') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            console.log('📢 Notification reçue :', body);
            res.writeHead(200); res.end('OK');
        });
    } else {
        res.writeHead(404); res.end();
    }
});

server.listen(PORT, () => console.log(`Notifier démarré sur le port ${PORT}`));
