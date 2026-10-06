server "example" {
	listen on egress port 80
	alias "www.example"
	
	root "/sites/example/htdocs"
	
	location "/.well-known/acme-challenge/*" {
		root "/acme"
		request strip 2
	}
}
