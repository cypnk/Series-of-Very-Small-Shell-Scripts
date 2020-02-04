table USERSactionindex file:/var/www/sites/example/mail/users

action "RECactionindex" maildir "~/Maildir/%{dest.domain}/%{dest.user}" junk virtual <USERSactionindex>
action "OUTactionindex" relay helo mail.example tls

match from any for domain "example" action "RECactionindex"
match from rdns "example" for any action "OUTactionindex"
match auth mail-from "@example" for any action "OUTactionindex"



