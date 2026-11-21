# Send a Signal to an application running as a Kubernetes pod

## Precondition
- A container is running inside a pod
  + image: ghcr.io/iximiuz/labs/kubernetes-debug/simple-app:v1.0.0

- Goal: send `SIGUSR1` signal to `app` process running in that container.

## How

- To send a signal to a linux process, we use `kill` command, `kill -SIGNAL PID`
  + SIGINT: interrupt like Ctrl+C
  + SIGKILL: forcefully terminate a process
  + SIGTERM: request a process to terminate
  + SIGSTOP/SIGCONT: pause/resume a process

- Start a shell inside the target container
  `k exec -it simple -c app -- sh`

- Find the PID using `ps` and send signal `kill -SIGUSR1 PID`