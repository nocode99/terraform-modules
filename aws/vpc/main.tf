resource "aws_vpc" "main" {
    cidr_block              = "${var.cidr_block}"
    enable_dns_support      = true
    enable_dns_hostnames    = true

    tags {
        Name                = "${var.name}-${var.env}"
        Env                 = "${var.env}"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id          = "${aws_vpc.main.id}"

    tags {
        Name        = "${var.name}-${var.env}"
        Env         = "${var.env}"
    }
}

resource "aws_subnet" "private" {
    count               = "${length(var.availability_zones)}"
    vpc_id              = "${aws_vpc.main.id}"
    cidr_block          = "${lookup(var.private_subnets, var.availability_zones[count.index])}"
    availability_zone   = "${element(var.availability_zones, count.index)}"
    tags {
        Name            = "${var.name}-${var.env}-${format("private-%02d", count.index+1)}"
        Env             = "${var.env}"
    }
}

resource "aws_subnet" "public" {
    count               = "${length(var.availability_zones)}"
    vpc_id              = "${aws_vpc.main.id}"
    cidr_block          = "${lookup(var.public_subnets, var.availability_zones[count.index])}"
    availability_zone   = "${element(var.availability_zones, count.index)}"
    tags {
        Name            = "${var.name}-${var.env}-${format("public-%02d", count.index+1)}"
        Env             = "${var.env}"
    }
}

resource "aws_eip" "nat" {
    count           = "${length(var.availability_zones)}"
    vpc             = true
}

resource "aws_nat_gateway" "main" {
    count           = "${length(var.availability_zones)}"
    allocation_id   = "${element(aws_eip.nat.*.id, count.index)}"
    subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"
    depends_on      = ["aws_internet_gateway.main"]

}

/*
 * Route Tables
 */

resource "aws_route_table" "private" {
    count               = "${length(var.availability_zones)}"
    vpc_id              = "${aws_vpc.main.id}"
    tags {
        Name            = "${var.name}-${var.env}-${format("private-%02d", count.index+1)}"
        Env             = "${var.env}"
    }
}

resource "aws_route_table" "public" {
    vpc_id          = "${aws_vpc.main.id}"
    tags {
        Name        = "${var.name}-${var.env}-public"
        Env         = "${var.env}"
    }
}

resource "aws_route" "private" {
    count                       = "${length(var.availability_zones)}"
    route_table_id              = "${element(aws_route_table.private.*.id, count.index)}"
    destination_cidr_block      = "0.0.0.0/0"
    nat_gateway_id              = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

resource "aws_route" "public" {
    route_table_id              = "${aws_route_table.public.id}"
    destination_cidr_block      = "0.0.0.0/0"
    gateway_id                  = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table_association" "private" {
    count           = "${length(var.availability_zones)}"
    subnet_id       = "${element(aws_subnet.private.*.id, count.index)}"
    route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
    count           = "${length(var.availability_zones)}"
    subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id  = "${element(aws_route_table.public.*.id, count.index)}"
}
