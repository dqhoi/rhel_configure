# Step 1: Run "lsblk -do name,vendor,model,size" to mount USB (Ex: sudo mount /dev/sda1 /mnt)
# Step 2: Run "sudo chown -R $USER:$USER /mnt"
# Step 3: Change directory to mount point (cd /mnt)
# Step 4: cd rhel_configure
# Step 5: Run python install.py