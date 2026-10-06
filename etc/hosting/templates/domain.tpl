domain example {
	alternative names { www.example  }
	domain key "/etc/ssl/private/example.key"
	domain full chain certificate "/etc/ssl/example.crt"
	sign with letsencrypt
}

