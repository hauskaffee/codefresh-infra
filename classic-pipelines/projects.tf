resource "codefresh_project" "luke-cf" {
  name = "luke-cf"
  tags = [
    "owner:luke",
    "terraform"
  ]
}