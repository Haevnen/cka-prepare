# Identify which port a service is using

- You have access to a Linux server running several services. How can you know which port that the `app` service is using.

## How

- Step 1: make sure the `app` service is running via `systemctl status app`

- Step 2: use `sudo ss -lp | grep -i app` -> display all listening port and process's name. 

![alt text](image.png)

NOTE: 
  + Must use `sudo` because the normal user don't have permission to view all processes
    `ss -lp | grep -i app` returns nothing
