resource "confluent_flink_compute_pool" "flink_pool" {
  display_name     = "default"
  cloud            =  upper(data.confluent_flink_region.flink_region.cloud)
  region           =  data.confluent_flink_region.flink_region.region
  max_cfu          = 50
  environment {
    id = confluent_environment.staging.id
  }
}

data "confluent_flink_region" "flink_region" {
  cloud  = "AWS"
  region = var.region
}
