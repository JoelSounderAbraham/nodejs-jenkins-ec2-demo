#!/usr/bin/env bash
set -euo pipefail

# Update these if needed:
EC2_USER="nodeapp"
EC2_HOST="${1:-ec2-xx-xx-xx-xx.compute.amazonaws.com}"
APP_DIR="/var/www/nodejs-jenkins-ec2-demo"

echo "[deploy] Uploading files to ${EC2_USER}@${EC2_HOST}:${APP_DIR} ..."

rsync -az --delete   --exclude node_modules   --exclude .git   --exclude coverage   ./ "${EC2_USER}@${EC2_HOST}:${APP_DIR}/"

echo "[deploy] Installing production dependencies on EC2 ..."
ssh -o StrictHostKeyChecking=no "${EC2_USER}@${EC2_HOST}" "
  set -e
  sudo mkdir -p ${APP_DIR}
  sudo chown -R \"${EC2_USER}\":\"${EC2_USER}\" ${APP_DIR}
  cd ${APP_DIR}
  npm ci --omit=dev
"
echo "[deploy] Done."
