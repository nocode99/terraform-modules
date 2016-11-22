output "vpc_id" {
    value   = "${aws_vpc.main.id}"
}

output "public_subnets" {
    value   = ["${aws_subnet.public.*.id}"]
}

output "private_subnets" {
    value   = ["${aws_subnet.private.*.id}"]
}

output "availability_zones" {
    value   = ["${var.availability_zones}"]
}

output "cidr_block" {
    value   = "${var.cidr_block}"
}

output "aws_route_table_private" {
    value   = ["${aws_route_table.private.*.id}"]
}

output "aws_route_table_public" {
    value   = "${aws_route_table.public.id}"
}
