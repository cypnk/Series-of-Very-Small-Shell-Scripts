
domain mail.example {
	domain key "/etc/ssl/private/mail.example.key"
	domain full chain certificate "/etc/ssl/mail.example.fullchain.pem"
	sign with letsencrypt
}

