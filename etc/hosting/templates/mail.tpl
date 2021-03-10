
server "mail.example" {
	listen on egress port 80
	block return 301 "https://example$REQUEST_URI"
	
#	root "/sites/mail/htdocs-unsecure"
}

server "mail.example" {
	listen on egress tls port 443
	include "/etc/hosting/acme.conf"
	include "/etc/hosting/blocked.conf"
	
	hsts max-age 31536000
	hsts subdomains
	tls {
		certificate "/etc/ssl/mail.example.pem"
		key "/etc/ssl/private/mail.example.key"		
	}
	root "/sites/mail/htdocs"
}
