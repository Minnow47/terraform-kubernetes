resource "aws_elb" "main" {
    name = "${var.elb_name}"
    subnets = ["${aws_subnet.main.id}"]
    cross_zone_load_balancing = "false"

    tags {
        KubernetesCluster = "${var.cluster_name}"
        "kubernetes.io/service-name" = "default/frontend"
    }

    // The 30xxx ports are defined by the frontend NodePort
    // service in k8s/{dev,prod}/default/frontend-svc.yaml
    listener {
        instance_port = 30080
        instance_protocol = "tcp"
        lb_port = 80
        lb_protocol = "tcp"
    }

    listener {
        instance_port = 30443
        instance_protocol = "tcp"
        lb_port = 443
        lb_protocol = "tcp"
    }

    health_check {
       // The number of checks before the instance is declared healthy.
       healthy_threshold = 2

       // The number of checks before the instance is declared unhealthy.
       unhealthy_threshold = 6

       // In seconds
       timeout = 5

       // In seconds
       interval = 10

       target = "TCP:30080"
    }

    instances = ["${aws_instance.minion.*.id}"]
}
