# Docker Kubernetes lab

## Enable systemd in WSL (IMPORTANT)

```powershel
notepad $env:USERPROFILE\.wslconfig
```

```bash
# add to file
[wsl2]
systemd=true
```

```bash
wsl --shutdown
```

## Generate SSH Keys (Host)
```bash
#on host
ssh-keygen -t ed25519 -f vm_lab_key
```

## SSH (Key-Only, No Passwords)
```bash
ssh -i ../../vm_lab_key admin@localhost -p 2222   # jumpbox
ssh -i ../../vm_lab_key admin@localhost -p 2223   # server
ssh -i ../../vm_lab_key admin@localhost -p 2224   # node-0
ssh -i ../../vm_lab_key admin@localhost -p 2225   # node-1
```

## Internal DNS (Bind9)

### Install Bind9 (on server)

```bash
sudo apt-get update
sudo apt install -y bind9 bind9utils
```

### Configure Named Options

```bash
sudo vi /etc/bind/named.conf.options
```

```vi
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { 172.30.0.0/24; };
    listen-on { 172.30.0.20; };
    allow-recursion { 172.30.0.0/24; };

    forwarders {
        8.8.8.8;
        1.1.1.1;
    };

    dnssec-validation auto;
};
```

### Create Zone File

```bash
sudo vi /etc/bind/named.conf.local
```

```vi
zone "lab.local" {
    type master;
    file "/etc/bind/db.lab.local";
};
```

### Create zone:
```bash
sudo vi /etc/bind/db.lab.local
```

```vi
$TTL    604800
@       IN      SOA     server.lab.local. admin.lab.local. (
                              2
                         604800
                          86400
                        2419200
                         604800 )

@       IN      NS      server.lab.local.

jumpbox IN      A       172.30.0.10
server  IN      A       172.30.0.20
node-0  IN      A       172.30.0.30
node-1  IN      A       172.30.0.40

```

### Restart DNS
```bash
sudo systemctl restart bind9
sudo systemctl enable bind9
```

### 2.5 Configure Clients to Use DNS

On each VM:

``` bash
sudo vi /etc/systemd/resolved.conf
```

```bash
[Resolve]
DNS=172.30.0.20
Domains=lab.local
```

```bash
sudo systemctl restart systemd-resolved
sudo systemctl status systemd-resolved
```

```bash
sudo vi /etc/resolv.conf
```

```bash
nameserver 172.30.0.20
search lab.local
options timeout:2 attempts:2
```

```bash
sudo chattr +i /etc/resolv.conf
```

Test:

```bash
ping server.lab.local
```