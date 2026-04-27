# 🌐 Redes (VPC)
resource "aws_vpc" "sre_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "sre-lab-vpc" }
}

# 🚪 Salida a Internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sre_vpc.id
}

# 📦 Subnet Pública 1 (AZ A)
resource "aws_subnet" "pub_a" {
  vpc_id                  = aws_vpc.sre_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "sre-pub-a" }
}

# 📦 Subnet Pública 2 (AZ B) - Redundancia Zero-Cost
resource "aws_subnet" "pub_b" {
  vpc_id                  = aws_vpc.sre_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "sre-pub-b" }
}

# 🛣️ Tabla de Rutas (Indica que todo tráfico vaya al IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sre_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# 🔗 Asociar Subnets con la Ruta
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pub_b.id
  route_table_id = aws_route_table.public_rt.id
}
