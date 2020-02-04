server "example" {
	listen on egress port 80
	alias "www.example"
	
	connection {
		max requests 5
		request timeout 10
	}
	
	include "/etc/hosting/blocked.conf"
	include "/etc/hosting/acme.conf"
	root "/sites/example/htdocs"
}

