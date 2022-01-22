module "builder_api" {
  source              = "simplycubed/cloud-run-cicd-updates/google"
  version             = "2.2.2"
  name                = "builder-api"
  image               = "gcr.io/${var.project_id}/${var.default_image}"
  location            = var.region
  map_domains         = ["api.${var.base_domain}"]
  allow_public_access = false
  env = [
    { key = "ENV", value = "${var.env}" },
    { key = "ALLOWED_ORIGIN", value = "*" },
    { key = "FIREBASE_URL", value = "simplycubed-builder-${var.env}.firebaseapp.com" },
    { key = "FIREBASE_CREDENTIALS", value = "/etc/secrets/firebase.json" },
    { key = "FIRESTORE_PROJECT_ID", value = "simplycubed-builder-${var.env}" },
    { key = "FRONTEND_URL", value = "https://app.${var.base_domain}" }
  ]
  volumes = [
    { path = "/etc/secrets", secret = "projects/${var.project_id}/secrets/firebase-service-account", versions = { "firebase.json" = "latest" } }
  ]
}

module "registry_api" {
  source              = "simplycubed/cloud-run-cicd-updates/google"
  version             = "2.2.2"
  name                = "registry-api"
  image               = "gcr.io/${var.project_id}/${var.default_image}"
  location            = var.region
  allow_public_access = false
  map_domains         = ["registry-api.${var.base_domain}"]
  env = [
    { key = "ENV", value = "${var.env}" },
    { key = "ALLOWED_ORIGIN", value = "*" },
    { key = "FIREBASE_URL", value = "simplycubed-builder-${var.env}.firebaseapp.com" },
    { key = "FIREBASE_CREDENTIALS", value = "/etc/secrets/firebase.json" },
    { key = "FIRESTORE_PROJECT_ID", value = "simplycubed-builder-${var.env}" },
    { key = "FRONTEND_URL", value = "https://app.simplycubed.${var.base_domain}" }
  ]
  volumes = [
    { path = "/etc/secrets", secret = "projects/${var.project_id}/secrets/firebase-service-account", versions = { "firebase.json" = "latest" } }
  ]
}

module "registry_etl" {
  source              = "simplycubed/cloud-run-cicd-updates/google"
  version             = "2.2.2"
  name                = "registry-etl"
  image               = "gcr.io/${var.project_id}/${var.default_image}"
  location            = var.region
  allow_public_access = false
  ingress             = "internal"
  map_domains         = ["registry-etl.${var.base_domain}"]
  env = [
    { key = "ENV", value = "${var.env}" },
    { key = "ALLOWED_ORIGIN", value = "*" },
    { key = "FIREBASE_URL", value = "simplycubed-builder-${var.env}.firebaseapp.com" },
    { key = "FIREBASE_CREDENTIALS", value = "/etc/secrets/firebase.json" },
    { key = "FIRESTORE_PROJECT_ID", value = "simplycubed-builder-${var.env}" },
    { key = "FRONTEND_URL", value = "https://app.simplycubed.${var.base_domain}" }
  ]
  volumes = [
    { path = "/etc/secrets", secret = "projects/${var.project_id}/secrets/firebase-service-account", versions = { "firebase.json" = "latest" } }
  ]
}
