USER=rich

#adduser $USER

echo $USER:partner123 | chpasswd

usermod -aG wheel $USER