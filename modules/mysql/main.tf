provider "mysql" {
  endpoint = var.db_host
  username = var.db_master
  password = var.db_master_password
}

resource "mysql_database" "main" {
  name               = var.db_name
}

resource "mysql_user" "main" {
  user               = var.db_username
  host               = "%"
  plaintext_password = var.db_password
}

resource "mysql_grant" "main" {
  user       = mysql_user.main.user
  host       = mysql_user.main.host
  database   = mysql_database.main.name
  privileges = ["EXECUTE", "SELECT", "DELETE", "INSERT", "UPDATE"]
}
