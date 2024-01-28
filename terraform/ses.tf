resource "aws_route53_record" "amazonses_dkim_record" {
  count = 3

  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.0.dkim_tokens, count.index)}._domainkey.${var.domain}"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.0.dkim_tokens, count.index)}.dkim.amazonses.com"]
  ttl     = "600"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.this.zone_id
}

resource "aws_route53_record" "amazonses_mx_record" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.region}.amazonaws.com"]
}

resource "aws_route53_record" "amazonses_verification_record" {
  name = "_amazonses.${var.domain}"

  records = [aws_ses_domain_identity.this.verification_token]
  ttl     = "600"
  type    = "TXT"
  zone_id = data.aws_route53_zone.this.zone_id
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  count = 1

  domain = join("", aws_ses_domain_identity.this.*.domain)
}

resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_receipt_rule" "this" {
  name          = var.environment
  rule_set_name = aws_ses_receipt_rule_set.this.rule_set_name

  enabled = true

  recipients = ["feedback@${var.domain}"]

  sns_action {
    topic_arn = aws_sns_topic.this.arn
    position  = 1
  }
}

resource "aws_ses_receipt_rule_set" "this" {
  rule_set_name = var.environment
}

