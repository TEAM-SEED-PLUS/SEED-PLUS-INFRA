### Step 1 — IP 포워딩 활성화 (sysctl)

# 즉시 적용
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
sudo sysctl -w net.ipv4.conf.default.send_redirects=0
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.default.accept_redirects=0

# 재부팅 후에도 유지
cat <<'EOF' | sudo tee /etc/sysctl.d/99-nat.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
EOF

sudo sysctl -p /etc/sysctl.d/99-nat.conf

### Step 2 — iptables 규칙 설정

# 초기화
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X

# ESTABLISHED/RELATED 먼저 추가 (기존 연결 보호)
sudo iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Loopback 허용
sudo iptables -A INPUT  -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# SSH inbound 허용
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# SSM Agent 아웃바운드 HTTPS 허용
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# DNS 아웃바운드 허용                                                                                                                                                          
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT                                                                                                                          
sudo iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# HTTP 아웃바운드 허용 (apt 저장소)
sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT

# Private Subnet → 인터넷 HTTP/HTTPS 포워딩
sudo iptables -A FORWARD -i ens5 -s 10.0.2.0/24 -p tcp --dport 80  -j ACCEPT
sudo iptables -A FORWARD -i ens5 -s 10.0.2.0/24 -p tcp --dport 443 -j ACCEPT
sudo iptables -A FORWARD -i ens5 -s 10.0.3.0/24 -p tcp --dport 80  -j ACCEPT
sudo iptables -A FORWARD -i ens5 -s 10.0.3.0/24 -p tcp --dport 443 -j ACCEPT

# MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o ens5 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.0.3.0/24 -o ens5 -j MASQUERADE

# 기본 정책 DROP (규칙 추가 완료 후 마지막에 적용)
sudo iptables -P INPUT   DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT  DROP

# 영구 저장
sudo apt update
sudo apt-get install -y iptables-persistent
sudo netfilter-persistent save

### 검증

# 포워딩 활성화 확인 (1이면 정상)
sysctl net.ipv4.ip_forward

# MASQUERADE 규칙 확인
sudo iptables -t nat -L POSTROUTING -n -v

# FORWARD 체인 확인
sudo iptables -L FORWARD -n -v

# App 또는 DB 인스턴스에 SSH 접속 후 아래로 외부 통신 확인:
curl -I https://google.com