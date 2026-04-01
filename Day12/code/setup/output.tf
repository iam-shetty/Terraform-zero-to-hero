output "vpc_id" {
  value = aws_vpc.my_vpc.id
}
output "subnet_id" {
  value = aws_subnet.my_subnet.id

}
output "vpc_name" {
  value = aws_vpc.my_vpc.tags["Name"]

}
output "subnet_name" {
  value = aws_subnet.my_subnet.tags["Name"]

}