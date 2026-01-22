resource "aws_route53_record" "opensearch-dns" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.name}.${var.domain_name}}"
  type    = "CNAME"
  records = [aws_opensearch_domain.opensearch.endpoint]
  ttl     = "300"
}