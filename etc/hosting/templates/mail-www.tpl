
server "mail.example" {
	listen on egress port 80
	include "/etc/hosting/blocked.conf"
	include "/etc/hosting/headers.conf"
	
	root "/sites/mail/htdocs-unsecure"
	
	location "/.well-known/acme-challenge/*" {
		root "/acme"
		request strip 2
	}
}

server "mail.example" {
	listen on egress tls port 443
	include "/etc/hosting/blocked.conf"
	include "/etc/hosting/headers.conf"
	
	root "/sites/mail/htdocs"
	
	hsts max-age 31536000
	hsts subdomains
	tls {
		certificate "/etc/ssl/mail.example.fullchain.pem"
		key "/etc/ssl/private/mail.example.key"
	}
	
	location "/.well-known/acme-challenge/*" {
		root "/acme"
		request strip 2
	}
}
