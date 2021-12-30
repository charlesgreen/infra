resource "random_id" "db_name_suffix" {
  byte_length = 3
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_sql_database_instance" "instance" {
  provider            = google-beta
  database_version    = "POSTGRES_13"
  name                = "private-instance-${random_id.db_name_suffix.hex}"
  region              = var.region
  deletion_protection = var.db_deletion_protection
  settings {
    tier = var.db_machine_type
    ip_configuration {
      ipv4_enabled    = false
      private_network = module.vpc.network_self_link
      require_ssl     = true
    }
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_ssl_cert" "cloudsql" {
  common_name = "cloudsql-certs"
  instance    = google_sql_database_instance.instance.name
}

resource "kubernetes_secret" "cloudsql_certs" {
  metadata {
    name = "cloudsql-certs"
  }
  data = {
    "client-key.pem"  = google_sql_ssl_cert.cloudsql.private_key
    "client-cert.pem" = google_sql_ssl_cert.cloudsql.cert
    "server-ca.pem"   = google_sql_ssl_cert.cloudsql.server_ca_cert
  }
}

# BUILDER
resource "google_sql_database" "builder" {
  name     = "builder"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "builder" {
  name     = var.cloudsql_username
  instance = google_sql_database_instance.instance.name
  password = var.cloudsql_password
}

resource "kubernetes_secret" "builder" {
  metadata {
    name = "cloudsql-builder"
  }
  data = {
    BUILDER_SQL_HOST     = google_sql_database_instance.instance.ip_address.0.ip_address
    BUILDER_SQL_PORT     = "5432"
    BUILDER_SQL_NAME     = google_sql_database.builder.name
    BUILDER_SQL_USER     = google_sql_user.builder.name
    BUILDER_SQL_PASS     = google_sql_user.builder.password
    BUILDER_SQL_CA_CERTS = google_sql_database_instance.instance.server_ca_cert[0].cert
  }
}

# REGISTRY
resource "google_sql_database" "registry" {
  name     = "registry"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "registry" {
  name     = var.cloudsql_username
  instance = google_sql_database_instance.instance.name
  password = var.cloudsql_password
}

resource "kubernetes_secret" "registry" {
  metadata {
    name = "cloudsql-registry"
  }
  data = {
    REGISTRY_SQL_HOST     = google_sql_database_instance.instance.ip_address.0.ip_address
    REGISTRY_SQL_PORT     = "5432"
    REGISTRY_SQL_NAME     = google_sql_database.registry.name
    REGISTRY_SQL_USER     = google_sql_user.registry.name
    REGISTRY_SQL_PASS     = google_sql_user.registry.password
    REGISTRY_SQL_CA_CERTS = google_sql_database_instance.instance.server_ca_cert[0].cert
  }
}
