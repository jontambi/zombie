resource "null_resource" "output" {
  provisioner "local-exec" {
    command     = "mkdir -p ${path.root}/output/${var.environment}-${var.cluster_name}"
    interpreter = ["bash", "-c"]
  }
}

resource "local_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = "${path.root}/output/${var.environment}-${var.cluster_name}/kubeconfig-${var.cluster_name}"

  depends_on = [null_resource.output]
}

resource "local_file" "aws_auth" {
  content  = local.aws_auth
  filename = "${path.root}/output/${var.environment}-${var.cluster_name}/aws-auth.yaml"

  depends_on = [null_resource.output]
}

#resource "null_resource" "kubectl" {
#  count = var.enable_kubectl ? 1 : 0

  #provisioner "local-exec" {
  #  command     = <<COMMAND
  #    cp ~/.kube/config ~/.kube/config.ORI \
  #    && export AWS_PROFILE=john.tambi \
  #  COMMAND
  #  interpreter = ["bash", "-c"]
  #}

  #triggers = {
  #  kubeconfig_rendered = local.kubeconfig
  #}

  #depends_on = [
  #  aws_eks_cluster.cluster,
  #  null_resource.output,
  #]
#}

resource "null_resource" "aws_auth" {
  provisioner "local-exec" {
    command     = <<COMMAND
      export AWS_PROFILE=john.tambi \
      && kubectl apply --kubeconfig=${path.root}/output/${var.environment}-${var.cluster_name}/kubeconfig-${var.cluster_name} -f ${path.root}/output/${var.environment}-${var.cluster_name}/aws-auth.yaml
    COMMAND
    interpreter = ["bash", "-c"]
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [
    local_file.aws_auth,
    aws_eks_cluster.cluster,
  ]
}