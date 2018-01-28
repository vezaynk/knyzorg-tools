echo "This will create a new swap file at /swapfile"
read -p "What size do you want it to be?" size
sudo fallocate -l $size /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

