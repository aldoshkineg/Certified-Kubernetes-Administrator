# Snip

Run pod command:
```yaml
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 3600; done']
```
```yaml
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command:
    - sh
    - c
    - while true; do echo hello; sleep 2; done
```

Nginx with custom port and welcome:
```yaml
    image: nginx
    command: ["/bin/sh"]
    args: ["-c", "echo 'worked' > /usr/share/nginx/html/index.html && echo 'server { listen 8080; root /usr/share/nginx/html; }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
    ports:
    - containerPort: 8080
```

Nginx with custom prefix:

```yaml
  - image: nginx
    command: ["/bin/sh","-c"]
    args: ["echo worked > /app; echo 'server { listen 8080; location = /app { alias /app; } }' > /etc/nginx/conf.d/default.conf; nginx -g 'daemon off;'"]
    ports:
    - containerPort: 8080
```

Images with colors:
```yaml
  containers:
  - name: webapp-green
    image: kodekloud/webapp-color
    args: ["--color","green"]
```
