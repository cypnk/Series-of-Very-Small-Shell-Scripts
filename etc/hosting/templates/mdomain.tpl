
domain mail.example {
	domain key "/etc/ssl/private/mail.example.key"
	domain certificate "/etc/ssl/mail.example.crt"
	domain full chain certificate "/etc/ssl/mail.example.pem"
	sign with letsencrypt
}

