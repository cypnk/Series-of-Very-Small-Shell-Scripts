server "www.example" {
	listen on egress port 80
	listen on egress tls port 443
	
	hsts max-age 31536000
	hsts subdomains
	tls {
		certificate "/etc/ssl/example.pem"
		key "/etc/ssl/private/example.key"
	}	
	block return 301 "https://example$REQUEST_URI"
}

server "example" {
	listen on egress port 80
	block return 301 "https://example$REQUEST_URI"
}

server "example" {
	listen on egress tls port 443
	include "/etc/hosting/blocked.conf"
	
	connection {
		max requests 100
		request timeout 10
	}
	
	directory index "index.html"
	
	log access "/sites/example/access.log"
	log error "/sites/example/error.log"
	
	root "/sites/example/htdocs"
	
	hsts max-age 31536000
	hsts subdomains
	tls {
		certificate "/etc/ssl/example.pem"
		key "/etc/ssl/private/example.key"
	}
	
	location "/.well-known/acme-challenge/*" {
		root "/acme"
		request strip 2
	}
}
