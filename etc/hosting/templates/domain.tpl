domain example {
	alternative names { www.example  }
	domain key "/etc/ssl/private/example.key"
	domain certificate "/etc/ssl/example.crt"
	domain full chain certificate "/etc/ssl/example.pem"
	sign with letsencrypt
}

