# ETCD Setup

## 1. Manual way
- Run command `curl -L https://github.com/etcd-io/etcd/releases/download/v3.3.11/etcd-v3.3.11-linux-amd64.tar.gz -o etcd-v3.3.11-linux-amd64.tar.gz`

- Extract and run etcd server `./etcd`. Open another terminal and start using with some basic command `./etcd --version`, `./etcd set key1 value1`, `./etcd get key1`