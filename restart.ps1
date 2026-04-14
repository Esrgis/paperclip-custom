Write-Host "=== Stopping containers ===" -ForegroundColor Cyan
cd D:\AI_Projects\paperclip\docker
docker-compose down

Write-Host "=== Starting containers ===" -ForegroundColor Cyan
docker-compose up --build -d

Write-Host "=== Waiting for server to start ===" -ForegroundColor Cyan
Start-Sleep 10

Write-Host "=== Installing Gemini CLI ===" -ForegroundColor Cyan
docker exec -u root docker-server-1 npm install -g @google/gemini-cli
docker exec -u root docker-server-1 mkdir -p /paperclip/.gemini
docker exec -u root docker-server-1 mkdir -p /home/node/.gemini
docker exec -u root docker-server-1 mkdir -p /root/.gemini

Write-Host "=== Disabling Gemini Sandbox ===" -ForegroundColor Cyan
'{"sandbox": false}' | docker exec -i -u root docker-server-1 tee /home/node/.gemini/settings.json
'{"sandbox": false}' | docker exec -i -u root docker-server-1 tee /root/.gemini/settings.json

Write-Host "=== Fixing permissions ===" -ForegroundColor Cyan
docker exec -u root docker-server-1 chown -R node:node /paperclip
docker exec -u root docker-server-1 chown -R node:node /home/node/.gemini

Write-Host "=== Fixing config ===" -ForegroundColor Cyan
docker exec -u root docker-server-1 sed -i s/local_trusted/authenticated/ /paperclip/instances/default/config.json
docker exec -u root docker-server-1 sed -i s/loopback/lan/ /paperclip/instances/default/config.json

Write-Host "=== Restarting server ===" -ForegroundColor Cyan
docker restart docker-server-1
Start-Sleep 8

Write-Host "=== Done! Open http://localhost:3100 ===" -ForegroundColor Green