#!/usr/bin/env bash
set -euo pipefail

EC2_USER="nodeapp"
EC2_HOST="${1:-ec2-xx-xx-xx-xx.compute.amazonaws.com}"
APP_DIR="/var/www/nodejs-jenkins-ec2-demo"
APP_NAME="nodejs-jenkins-ec2-demo"
START_CMD="npm start"

echo "[restart] Restarting app via PM2 on ${EC2_HOST} ..."
ssh -o StrictHostKeyChecking=no "${EC2_USER}@${EC2_HOST}" "
  set -e
  cd ${APP_DIR}
  pm2 start '${START_CMD}' --name ${APP_NAME} || pm2 restart ${APP_NAME}
  pm2 save
"
echo "[restart] Done."
