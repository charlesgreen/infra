module "dns" {
  source     = "terraform-google-modules/cloud-dns/google"
  type       = "public"
  project_id = var.project_id
  name       = "site-dns"
  domain     = "${var.base_domain}."
  recordsets = [
    {
      name = "www"
      type = "A"
      ttl  = 60
      records = [
        "199.36.158.100",
      ]
    },
    {
      name = ""
      type = "A"
      ttl  = 60
      records = [
        "199.36.158.100",
      ]
    },
    {
      name = ""
      type = "MX"
      ttl  = 300
      records = [
        "1 aspmx.l.google.com.",
        "5 alt1.aspmx.l.google.com.",
        "5 alt2.aspmx.l.google.com.",
        "10 alt3.aspmx.l.google.com.",
        "10 alt4.aspmx.l.google.com."
      ]
    },
    {
      name = "google._domainkey"
      type = "TXT"
      ttl  = 300
      records = [
        "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCSQD70OQFtP0sBMXMJeS3g240/6HTvnxNBFdRNcXEkRTacv/yUo4JvkpbRo4JmxBbDwytlgRnDcMtqRd7iDc3XXZKh4ABzPGA+7imSCnc2hdbosStSYo+mAsfW0fssGnd84kwichH1btLhcHGrv2NF8HJjNlpYebgaUF1XbVlx2QIDAQAB\"",
        "\"keybase-site-verification=cXZgwWV_Lwf9_RHVXtl33X5jWlCHI3KbvcNHOx7_Ts8\""
      ]
    },
    {
      name = ""
      type = "TXT"
      ttl  = 300
      records = [
        "\"v=spf1 include:_spf.google.com include:_spf.firebasemail.com include:sendgrid.net ~all\""
      ]
    },
    {
      name = ""
      type = "SPF"
      ttl  = 300
      records = [
        "\"v=spf1 include:_spf.google.com include:_spf.firebasemail.com include:sendgrid.net ~all\""
      ]
    },
    {
      name = "_dmarc"
      type = "TXT"
      ttl  = 300
      records = [
        "\"v=DMARC1;\" \"p=quarantine;\" \"rua=mailto:dmarc@${var.base_domain};\" \"ruf=mailto:dmarc@${var.base_domain};\" \"fo=1:d:s\""
      ]
    },
    {
      name = "25532353"
      type = "CNAME"
      ttl  = 60
      records = [
        "sendgrid.net.",
      ]
    },
    {
      name = "em4847"
      type = "CNAME"
      ttl  = 60
      records = [
        "u25532353.wl104.sendgrid.net.",
      ]
    },
    {
      name = "s1._domainkey"
      type = "CNAME"
      ttl  = 60
      records = [
        "s1.domainkey.u25532353.wl104.sendgrid.net.",
      ]
    },
    {
      name = "s2._domainkey"
      type = "CNAME"
      ttl  = 60
      records = [
        "s2.domainkey.u25532353.wl104.sendgrid.net.",
      ]
    },
    {
      name = "url5910"
      type = "CNAME"
      ttl  = 60
      records = [
        "sendgrid.net.",
      ]
    },
  ]
}
