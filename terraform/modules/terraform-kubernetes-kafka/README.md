# terraform-kubernetes-kafka

Module to provision Strimzi Kafka operator (https://github.com/strimzi/strimzi-kafka-operator).
Includes example manifest file to be used to deploy Kafka (based on existing files). Note that these are only examples and would need to be adjusted to match real deployment.

## Important notes:
* Does not provision Kafka by itself, only operator. Kafka needs to be provisioned via yaml manifest files using CRDs
* Uses helm chart provided by strimzi (https://github.com/strimzi/strimzi-kafka-operator/tree/main/helm-charts/helm3/strimzi-kafka-operator)
* Upgrades require additional attention because CRDs are not upgraded automatically. See https://github.com/strimzi/strimzi-kafka-operator/tree/main/helm-charts/helm3/strimzi-kafka-operator#upgrading-your-clusters for more details

## Useful links:
* Github (https://github.com/strimzi/strimzi-kafka-operator)
* Website (https://strimzi.io/)
* Documentation (https://strimzi.io/documentation/)
   * Deployment/Upgrade docs (https://strimzi.io/docs/operators/latest/deploying.html)
   * More detailed usage docs (https://strimzi.io/docs/operators/latest/using.html)
* Helm chart (https://github.com/strimzi/strimzi-kafka-operator/tree/main/helm-charts/helm3/strimzi-kafka-operator)

## Example usage

Values provided are just examples and would need to be adjusted

```
module "kafka" {
  source = "cloud-deployment/terraform/modules/terraform-kubernetes-kafka"

  name                = "kafka"
  namespace           = "kafka-operator"
  namespaces_to_watch = ["kafka"]
  node_selector       = "node.kubernetes.io/instance-type: t3.xlarge"
  toleration = {
    key      = "kafka"
    operator = "Equal"
    effect   = "NoSchedule"
  }
}
```
