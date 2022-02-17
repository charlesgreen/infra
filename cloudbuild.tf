#
# firebase
#
resource "google_cloudbuild_trigger" "push_firebase_base_image" {
  name = "push-firebase-base-image"
  github {
    owner = "simplycubed"
    name  = "firebase"
    push {
      branch = "^main$"
    }
  }
  filename = "cloudbuild.yaml"
  tags     = ["managed by terraform"]
}

#
# node
#
resource "google_cloudbuild_trigger" "push_node_base_image" {
  name = "push-node-base-image"
  github {
    owner = "simplycubed"
    name  = "node"
    push {
      branch = "^main$"
    }
  }
  filename = "cloudbuild.yaml"
  tags     = ["managed by terraform"]
}

#
# simplycubed-web
#
resource "google_cloudbuild_trigger" "deploy_simplyhey_web" {
  name = "deploy-simplyhey-web"
  github {
    owner = "simplycubed"
    name  = "simplyhey-web"
    push {
      branch = "^main$"
    }
  }
  substitutions = {
    _FIREBASE_API_KEY             = var.firebase_api_key
    _FIREBASE_APP_ID              = var.firebase_app_id
    _FIREBASE_AUTH_DOMAIN         = var.firebase_auth_domain
    _FIREBASE_MEASUREMENT_ID      = var.firebase_measurement_id
    _FIREBASE_MESSAGING_SENDER_ID = var.firebase_messaging_sender_id
    _FIREBASE_STORAGE_BUCKET      = var.firebase_storage_bucket
  }
  filename = "cloudbuild.main.yaml"
  tags     = ["managed by terraform"]
}

resource "google_cloudbuild_trigger" "build_simplyhey_web" {
  name = "build-simplyhey-web"
  github {
    owner = "simplycubed"
    name  = "simplyhey-web"
    pull_request {
      branch = ".*"
    }
  }
  substitutions = {
    _FIREBASE_API_KEY             = var.firebase_api_key
    _FIREBASE_APP_ID              = var.firebase_app_id
    _FIREBASE_AUTH_DOMAIN         = var.firebase_auth_domain
    _FIREBASE_MEASUREMENT_ID      = var.firebase_measurement_id
    _FIREBASE_MESSAGING_SENDER_ID = var.firebase_messaging_sender_id
    _FIREBASE_STORAGE_BUCKET      = var.firebase_storage_bucket
  }
  filename = "cloudbuild.pr.yaml"
  tags     = ["managed by terraform"]
}
